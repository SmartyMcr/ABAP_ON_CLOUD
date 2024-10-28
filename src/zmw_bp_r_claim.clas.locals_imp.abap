CLASS lsc_zmw_r_claim DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zmw_r_claim IMPLEMENTATION.

  METHOD save_modified.

* Add extra logic here i.e. logging
    IF update-claim IS NOT INITIAL.
**********************************************************************
*      then write the log
**********************************************************************
    ENDIF.

*Here:
*    DATA: travel_log_update TYPE STANDARD TABLE OF /dmo/log_travel,
*          final_changes     TYPE STANDARD TABLE OF /dmo/log_travel.
*
*    IF update-travel IS NOT INITIAL.
*
*      travel_log_update = CORRESPONDING #( update-travel MAPPING
*                                              travel_id = TravelId
*       ).
*
*      LOOP AT update-travel ASSIGNING FIELD-SYMBOL(<travel_log_update>).
*
*        ASSIGN travel_log_update[ travel_id = <travel_log_update>-TravelId ]
*            TO FIELD-SYMBOL(<travel_log_db>).
*
*        GET TIME STAMP FIELD <travel_log_db>-created_at.
*
*        IF <travel_log_update>-%control-CustomerId = if_abap_behv=>mk-on.
*
*          <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
*          <travel_log_db>-changed_field_name = 'anubhav_customer'.
*          <travel_log_db>-changed_value = <travel_log_update>-CustomerId.
*          <travel_log_db>-changing_operation = 'CHANGE'.
*
*          APPEND <travel_log_db> TO final_changes.
*
*        ENDIF.
*
*        IF <travel_log_update>-%control-AgencyId = if_abap_behv=>mk-on.
*
*          <travel_log_db>-change_id = cl_system_uuid=>create_uuid_x16_static( ).
*          <travel_log_db>-changed_field_name = 'anubhav_agency'.
*          <travel_log_db>-changed_value = <travel_log_update>-AgencyId.
*          <travel_log_db>-changing_operation = 'CHANGE'.
*
*          APPEND <travel_log_db> TO final_changes.
*
*        ENDIF.
*
*      ENDLOOP.
*
*      INSERT /dmo/log_travel FROM TABLE @final_changes.
*
*    ENDIF.


  ENDMETHOD.

ENDCLASS.

CLASS lhc_zmw_r_claim DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Claim
        RESULT result,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE Claim,
      copyClaim FOR MODIFY
        IMPORTING keys FOR ACTION Claim~copyClaim,
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING keys REQUEST requested_features FOR Claim RESULT result,
      reCalcTotalPrice FOR MODIFY
        IMPORTING keys FOR ACTION Claim~reCalcTotalPrice.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Claim~calculateTotalPrice.
    METHODS validateHeaderData FOR VALIDATE ON SAVE
      IMPORTING keys FOR Claim~validateHeaderData.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Claim.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Claim.
    METHODS closeClaim FOR MODIFY
      IMPORTING keys FOR ACTION Claim~closeClaim RESULT result.

    METHODS rejectClaim FOR MODIFY
      IMPORTING keys FOR ACTION Claim~rejectClaim RESULT result.

    METHODS earlynumbering_cba_Subclaim FOR NUMBERING
      IMPORTING entities FOR CREATE Claim\_Subclaim.

    TYPES: t_entity_create TYPE TABLE FOR CREATE zmw_r_claim,
           t_entity_update TYPE TABLE FOR UPDATE zmw_r_claim,
           t_entity_rep    TYPE TABLE FOR REPORTED zmw_r_claim,
           t_entity_err    TYPE TABLE FOR FAILED zmw_r_claim.

    METHODS precheck_claim_reuse
      IMPORTING
        entities_u TYPE t_entity_update OPTIONAL
        entities_c TYPE t_entity_create OPTIONAL
      EXPORTING
        reported   TYPE t_entity_rep
        failed     TYPE t_entity_err.

ENDCLASS.

CLASS lhc_zmw_r_claim IMPLEMENTATION.

  METHOD get_global_authorizations.

*  This is an instance example
*    data : ls_result type ZMW_R_CLAIM.
*
*    "Step 1: Get the data of my instance
*    READ ENTITIES OF zmw_r_claim in LOCAL MODE
*        ENTITY Claim
*            fields ( Claim Status )
*                WITH CORRESPONDING #( keys )
*                    RESULT data(lt_claim)
*                    FAILED data(ls_failed).
*
*    "Step 2: loop at the data
*    loop at lt_claim into data(ls_claim).
*
*        "Step 3: Check if the instance was having status = cancelled
*        if ( ls_travel-OverallStatus = 'X' ).
*            data(lv_auth) = abap_false.
*
*            "Step 4: Check for authorization in org
**            AUTHORITY-CHECK OBJECT 'CUSTOM_OBJ'
**                ID 'FIELD_NAME' FIELD field1
**            IF sy-subrc = 0.
**                lv_auth = abap_true.
**            ENDIF.
*        else.
*            lv_auth = abap_true.
*        ENDIF.
*
*        ls_result = value #( Claim = ls_claim-Claim
*                             %update = COND #( when lv_auth eq abap_false
*                                                    then if_abap_behv=>auth-unauthorized
*                                                    else    if_abap_behv=>auth-allowed
*                                             )
*                             %action-copyClaim = COND #( when lv_auth eq abap_false
*                                                    then if_abap_behv=>auth-unauthorized
*                                                    else    if_abap_behv=>auth-allowed
*                                             )
*        ).
*
*        ""Finally send the result out to RAP
*        APPEND ls_result to result.
*
*    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: entity       TYPE STRUCTURE FOR CREATE zmw_r_claim,
          claim_id_max TYPE /dmo/travel_id. "NUMC

    ""Step 1: Ensure that Travel id is not set for the record which is coming
    LOOP AT entities INTO entity WHERE Claim IS NOT INITIAL.
      APPEND CORRESPONDING #( entity ) TO mapped-claim.
    ENDLOOP.

    DATA(entities_wo_claimno) = entities.
    DELETE entities_wo_claimno WHERE claim IS NOT INITIAL.

    ""Step 2: Get the sequence numbers from the SNRO
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = CONV #( '/DMO/TRAVL' )
            quantity          =  CONV #( lines( entities_wo_claimno ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        ""Step 3: If there is an exception, we will throw the error
        LOOP AT entities_wo_claimno INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
              TO reported-claim.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key ) TO failed-claim.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        ""Step 4: Handle especial cases where the number range exceed critical %
        LOOP AT entities_wo_claimno INTO entity.
          APPEND VALUE #( %cid = entity-%cid %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning
                          ) )
              TO reported-claim.
        ENDLOOP.
      WHEN '2' OR '3'.
        ""Step 5: The number range return last number, or number exhaused
*        APPEND VALUE #( %cid = entity-%cid %key = entity-%key
*                            %msg = NEW /dmo/cm_flight_messages(
*                                        textid = /dmo/cm_flight_messages=>not_sufficient_numbers
*                                        severity = if_abap_behv_message=>severity-warning
*                            ) )
*                TO reported-travel.
*        APPEND VALUE #( %cid = entity-%cid
*                        %key = entity-%key
*                        %fail-cause = if_abap_behv=>cause-conflict
*                         ) TO failed-travel.

        LOOP AT entities_wo_claimno INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-claim.
          APPEND VALUE #( %cid        = entity-%cid
                          %key        = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict
                        ) TO failed-claim.
        ENDLOOP.
        EXIT.
    ENDCASE.

    ""Step 6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_claimno ).

    ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
    ""        return MAPPED data which will then go to RAP framework
    claim_id_max = number_range_key - number_range_returned_quantity.

    LOOP AT entities_wo_claimno INTO entity.

      claim_id_max += 1.
      entity-Claim = claim_id_max.
      SHIFT entity-Claim LEFT DELETING LEADING '0'.
      APPEND VALUE #( %cid = entity-%cid
                      %key = entity-%key
*                      TODO WHEN DRAFT ENABLED"Missed the draft setting for number range
                      %is_draft = entity-%is_draft ) TO mapped-claim.
    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_cba_Subclaim.

    DATA lt_subclaims TYPE SORTED TABLE OF zmw_subclaim WITH UNIQUE KEY claim subclaim.
    DATA max_subclaim_id TYPE zmw_i_subclaim-subclaim.

    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
      ENTITY Claim BY \_Subclaim
      FROM CORRESPONDING #( entities )
      LINK DATA(Subclaim).

    ""Loop at unique claim nos
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<claim_group>) GROUP BY <claim_group>-Claim.
      LOOP AT Subclaim INTO DATA(ls_subclaim)
       WHERE source-Claim =  <claim_group>-Claim.
        IF max_subclaim_id < ls_subclaim-target-subclaim.
          max_subclaim_id = ls_subclaim-target-subClaim.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    ""Step 3: get the assigned claim numbers for incoming request
    LOOP AT entities INTO DATA(ls_entity)
        WHERE Claim = <claim_group>-Claim.
      LOOP AT ls_entity-%target INTO DATA(ls_target).
        IF max_subclaim_id < ls_target-subclaim.
          max_subClaim_id = ls_target-subclaim.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    ""Step 4: loop over all the entities of travel with same travel id

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<claim>)
        WHERE Claim = <claim_group>-Claim.
      ""Step 5: assign new Claim IDs to the Subclaim entity inside each Claim
      LOOP AT <claim>-%target ASSIGNING FIELD-SYMBOL(<subclaim_wo_numbers>).
        APPEND CORRESPONDING #( <subclaim_wo_numbers> ) TO mapped-subclaim
        ASSIGNING FIELD-SYMBOL(<mapped_subclaim>).
        IF <mapped_Subclaim>-Subclaim IS INITIAL.

          max_subclaim_id += 1.
          "missed the draft settings for the booking number
          "TODO DRAFT LATER
          <mapped_subclaim>-%is_draft = <subclaim_wo_numbers>-%is_draft.
          <mapped_subclaim>-Subclaim = max_subclaim_id.
        ENDIF.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

  METHOD copyClaim.

    DATA: claims        TYPE TABLE FOR CREATE zmw_r_claim\\Claim,
          subclaims_cba TYPE TABLE FOR CREATE zmw_r_claim\\Claim\_Subclaim,
          pay_cba       TYPE TABLE FOR CREATE zmw_r_claim\\Subclaim\_Pay.

    "Step 1: Remove the travel instances with initial %cid
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_initial_cid).
    ASSERT key_with_initial_cid IS INITIAL.

    "Step 2: Read all travel, booking and booking supplement using EML
    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
    ENTITY Claim
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(claim_read_result)
        FAILED failed.

    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
    ENTITY Claim BY \_Subclaim
        ALL FIELDS WITH CORRESPONDING #( claim_read_result )
        RESULT DATA(subclaim_read_result)
        FAILED failed.

    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
    ENTITY subclaim BY \_Pay
        ALL FIELDS WITH CORRESPONDING #( subclaim_read_result )
        RESULT DATA(pay_read_result)
        FAILED failed.

    "Step 3: Fill travel internal table for travel data creation - %cid - abc123
    LOOP AT claim_read_result ASSIGNING FIELD-SYMBOL(<claim>).

      "Travel data prepration
      APPEND VALUE #( %cid = keys[ %tky = <claim>-%tky ]-%cid
                     %data = CORRESPONDING #( <claim> EXCEPT claim )
      ) TO claims ASSIGNING FIELD-SYMBOL(<new_claim>).

      <new_claim>-Opendate = CONV #( cl_abap_context_info=>get_system_date( ) ).
      <new_claim>-Lossdate = CONV #( cl_abap_context_info=>get_system_date( ) - 30 ).
      <new_claim>-Status = 'O'.

      "Step 3: Fill booking internal table for booking data creation - %cid_ref - abc123
      APPEND VALUE #( %cid_ref = keys[ %tky = <claim>-%tky ]-%cid )
        TO subclaims_cba ASSIGNING FIELD-SYMBOL(<subclaim_cba>).

      LOOP AT  subclaim_read_result ASSIGNING FIELD-SYMBOL(<subclaim>) WHERE Claim = <claim>-Claim.

        APPEND VALUE #( %cid = keys[ %tky = <claim>-%tky ]-%cid && <subclaim>-Claim
                        %data = CORRESPONDING #( subclaim_read_result[ %tky = <subclaim>-%tky ] EXCEPT Claim )
        )
            TO <subclaim_cba>-%target ASSIGNING FIELD-SYMBOL(<new_subclaim>).

        <new_subclaim>-Status = 'N'.

        "Step 4: Fill booking supplement internal table for booking suppl data creation
*        APPEND VALUE #( %cid_ref = keys[ %tky = <claim>-%tky ]-%cid && <subclaim>-Subclaim )
*                TO pay_cba ASSIGNING FIELD-SYMBOL(<pay_cba>).
*
*        LOOP AT pay_read_result ASSIGNING FIELD-SYMBOL(<pay>)
*             WHERE Claim = <claim>-Claim AND
*                                   Subclaim = <subclaim>-Subclaim.
*
*          APPEND VALUE #( %cid = keys[  %tky = <claim>-%tky ]-%cid && <subclaim>-Subclaim && <pay>-payment
*                      %data = CORRESPONDING #( <pay> EXCEPT Claim Subclaim )
*          )
*          TO <pay_cba>-%target.
*
*        ENDLOOP.
      ENDLOOP.


    ENDLOOP.

    "Step 5: MODIFY ENTITY EML to create new BO instance using existing data
    MODIFY ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY claim
            CREATE FIELDS ( ClaimDesc Clmtype Lossdate Opendate Policy Polprod Status )
*            AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                WITH claims
                    CREATE BY \_Subclaim FIELDS ( Complexity Coverage Opendate Status Subclaim Subcltype )
                        WITH subclaims_cba
*                            ENTITY Subclaim
*                                CREATE BY \_Pay FIELDS ( Bentype CurrencyCode Pampaid PayStat Payment )
*                                    WITH pay_cba
        MAPPED DATA(mapped_create).

    mapped-Claim = mapped_create-claim.


  ENDMETHOD.

  METHOD get_instance_features.

    "Step 1: Read the travel data with status
    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY claim
            FIELDS ( claim status )
            WITH     CORRESPONDING #( keys )
        RESULT DATA(claims)
        FAILED failed.

    "Step 2: return the result with booking creation possible or not
    READ TABLE claims INTO DATA(ls_claim) INDEX 1.

    IF ( ls_claim-Status = 'N' ).
      DATA(lv_allow) = if_abap_behv=>fc-o-disabled.
    ELSE.
      lv_allow = if_abap_behv=>fc-o-enabled.
    ENDIF.

    result = VALUE #( FOR claim IN claims
                        ( %tky = claim-%tky
                        %assoc-_Subclaim = lv_allow )
                        ).
*                          %action-acceptClaim = COND #( WHEN ls_claim-Status = 'O'
*                                                                            then if_abap_behv=>fc-o-disabled
*                                                                            else if_abap_behv=>fc-o-enabled
*                          )
*                          %action-rejectClaim = COND #( WHEN ls_claim-Status = 'C'
*                                                                            then if_abap_behv=>fc-o-disabled
*                                                                            else if_abap_behv=>fc-o-enabled
*                          )
*                          %assoc-_Subclaim = lv_allow
*                        )
*                    ).



  ENDMETHOD.

  METHOD reCalcTotalPrice.
*    Define a structure where we can store all the booking fees and currency code
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.

    DATA : amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.

*    Read all travel instances, subsequent bookings using EML
    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
       ENTITY Claim
       FIELDS ( BookingFee CurrencyCode )
       WITH CORRESPONDING #( keys )
       RESULT DATA(claims).

    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
       ENTITY Claim BY \_Subclaim
       FIELDS ( TotalPaid CurrencyCode )
       WITH CORRESPONDING #( claims )
       RESULT DATA(subclaims).

    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
       ENTITY Subclaim BY \_Pay
       FIELDS ( pampaid CurrencyCode )
       WITH CORRESPONDING #( subclaims )
       RESULT DATA(payments).

*    Delete the values w/o any currency
    DELETE claims WHERE CurrencyCode IS INITIAL.
    DELETE subclaims WHERE CurrencyCode IS INITIAL.
    DELETE payments WHERE CurrencyCode IS INITIAL.

*    Total all booking and supplement amounts which are in common currency
    LOOP AT claims ASSIGNING FIELD-SYMBOL(<claim>).
      "Set the first value for total price by adding the booking fee from header
      amounts_per_currencycode = VALUE #( ( amount = <claim>-BookingFee
                                          currency_code = <claim>-CurrencyCode ) ).

*    Loop at all amounts and compare with target currency
      LOOP AT subclaims INTO DATA(subclaim) WHERE Claim = <claim>-Claim.

        COLLECT VALUE ty_amount_per_currency( amount = subclaim-TotalPaid
                                              currency_code = subclaim-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      LOOP AT payments INTO DATA(payment) WHERE Claim = <claim>-Claim.

        COLLECT VALUE ty_amount_per_currency( amount = payment-Pampaid
                                              currency_code = subclaim-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      CLEAR <claim>-TotalPrice.
*    Perform currency conversion
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

        IF amount_per_currencycode-currency_code = <claim>-CurrencyCode.
          <claim>-TotalPrice += amount_per_currencycode-amount.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <claim>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(total_booking_amt)
          ).

          <claim>-TotalPrice = <claim>-TotalPrice + total_booking_amt.
        ENDIF.

      ENDLOOP.
*    Put back the total amount

    ENDLOOP.
*    Return the total amount in mapped so the RAP will modify this data to DB
    MODIFY ENTITIES OF zmw_r_claim IN LOCAL MODE
    ENTITY claim
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( claims ).

  ENDMETHOD.

  METHOD calculateTotalPrice.
    MODIFY ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY Claim
            EXECUTE reCalcTotalPrice
            FROM CORRESPONDING #( keys ).
  ENDMETHOD.

  METHOD validateHeaderData.

    "Step 1: Read the travel data
    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY Claim
        FIELDS ( Claim )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_claim).

    "Step 2: Declare a sorted table for holding customer ids
    DATA polprods TYPE SORTED TABLE OF zmw_i_polprod WITH UNIQUE KEY polprod.

    "Step 3: Extract the unique customer IDs in our table
    polprods = CORRESPONDING #( lt_claim DISCARDING DUPLICATES MAPPING
                                       polprod = polprod EXCEPT *
     ).

    DELETE polprods WHERE polprod IS INITIAL.

    ""Get the validation done to get all customer ids from db
    ""these are the IDs which are present
    IF polprods IS NOT INITIAL.

      SELECT FROM zmw_i_polprod FIELDS polprod
      FOR ALL ENTRIES IN @polprods
      WHERE polprod = @polprods-polprod
      INTO TABLE @DATA(lt_cust_db).

    ENDIF.

    ""loop at travel data
    LOOP AT lt_claim INTO DATA(ls_claim).

      IF ( ls_claim-polprod IS INITIAL OR
           NOT  line_exists(  lt_cust_db[ polprod = ls_claim-polprod ] ) ).

        ""Inform the RAP framework to terminate the create
        APPEND VALUE #( %tky = ls_claim-%tky ) TO failed-claim.
        APPEND VALUE #( %tky = ls_claim-%tky
                        %element-polprod = if_abap_behv=>mk-on
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>status_invalid
                                      status                = CONV #( ls_claim-polprod )
                                      severity              = if_abap_behv_message=>severity-error

        )
        ) TO reported-claim.

      ENDIF.

      IF ls_claim-opendate < ls_claim-lossdate.  "end_date before begin_date

        APPEND VALUE #( %tky = ls_claim-%tky ) TO failed-claim.

        APPEND VALUE #( %tky = ls_claim-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = ls_claim-opendate
                                   end_date   = ls_claim-lossdate
                                   travel_id  = CONV #( ls_claim-claim ) )
                        %element-Opendate    = if_abap_behv=>mk-on
                        %element-lossdate     = if_abap_behv=>mk-on
                     ) TO reported-claim.

      ELSEIF ls_claim-opendate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %tky        = ls_claim-%tky ) TO failed-claim.

        APPEND VALUE #( %tky = ls_claim-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-opendate    = if_abap_behv=>mk-on
                        %element-lossdate    = if_abap_behv=>mk-on
                      ) TO reported-claim.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD precheck_create.

      precheck_claim_reuse(
      EXPORTING
*        entities_u =
         entities_c = entities
      IMPORTING
        reported   = reported-claim
        failed     = failed-claim
    ).

  ENDMETHOD.

  METHOD precheck_update.

    precheck_claim_reuse(
      EXPORTING
        entities_u = entities
*         entities_c = entities
      IMPORTING
        reported   = reported-claim
        failed     = failed-claim

    ).
  ENDMETHOD.

  METHOD precheck_claim_reuse.
    ""Step 1: Data declaration
    DATA: entities  TYPE t_entity_update,
          operation TYPE if_abap_behv=>t_char01,
          polprods  TYPE SORTED TABLE OF zmw_i_polprod WITH UNIQUE KEY polprod,
          clmtypes  TYPE SORTED TABLE OF zmw_i_cltype WITH UNIQUE KEY clmtype.

    ""Step 2: Check either entity_c was passed or entity_u was passed
    ASSERT NOT ( entities_c IS INITIAL EQUIV entities_u IS INITIAL ).

    ""Step 3: Perform validation only if agency OR customer was changed
    IF entities_c IS NOT INITIAL.
      entities = CORRESPONDING #( entities_c ).
      operation = if_abap_behv=>op-m-create.
    ELSE.
      entities = CORRESPONDING #( entities_u ).
      operation = if_abap_behv=>op-m-update.
    ENDIF.

    DELETE entities WHERE %control-polprod = if_abap_behv=>mk-off OR %control-Clmtype = if_abap_behv=>mk-off.

    ""Step 4: get all the unique agencies and customers in a table
    polprods = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING polprod = polprod EXCEPT * ).
    clmtypes = CORRESPONDING #( entities DISCARDING DUPLICATES MAPPING clmtype = clmtype EXCEPT * ).

    ""Step 5: Select the agency and customer data from DB tables
    SELECT FROM zmw_i_polprod FIELDS polprod
    FOR ALL ENTRIES IN @polprods WHERE polprod = @polprods-polprod
    INTO TABLE @DATA(polprod_codes).

    SELECT FROM zmw_i_cltype FIELDS clmtype
    FOR ALL ENTRIES IN @clmtypes WHERE clmtype = @clmtypes-clmtype
    INTO TABLE @DATA(clmtype_codes).

    ""Step 6: Loop at incoming entities and compare each agency and customer country
    LOOP AT entities INTO DATA(entity).
      READ TABLE polprod_codes WITH KEY polprod = entity-polprod INTO DATA(ls_polprod).
      IF sy-subrc <> 0.
        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                                  %is_draft = entity-%is_draft
                                  %fail-cause = if_abap_behv=>cause-conflict ) TO failed.
      ENDIF.
      READ TABLE clmtype_codes WITH KEY clmtype = entity-clmtype INTO DATA(ls_clmtype).
      IF sy-subrc <> 0.
        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                                  %is_draft = entity-%is_draft
                                  %fail-cause = if_abap_behv=>cause-conflict ) TO failed.
      ENDIF.


      IF failed IS NOT INITIAL.

        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
                                  %is_draft = entity-%is_draft
                                  %msg = NEW /dmo/cm_flight_messages(
                                                                      textid                = VALUE #(
                                                                      msgid = 'SY'
                                                                      msgno = 499
                                                                      attr1 = 'problem with polprod or cltype'
                                                                       )
                                                                      agency_id             = CONV #( entity-polprod )
                                                                      customer_id           = CONV #( entity-clmtype )
                                                                      severity  = if_abap_behv_message=>severity-error
                                                                      )
                                  %element-polprod = if_abap_behv=>mk-on
          ) TO reported.

      ENDIF.
*      CHECK sy-subrc = 0.
*      READ TABLE clmtype_codes WITH KEY clmtype = entity-clmtype INTO DATA(ls_clmtype).
*      CHECK sy-subrc = 0.
*      IF ls_agency-country_code <> ls_customer-country_code.
*        ""Step 7: if country doesnt match, throw the error
*        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
*                                  %is_draft = entity-%is_draft
*                                  %fail-cause = if_abap_behv=>cause-conflict
*          ) TO failed.
*
*        APPEND VALUE #(    %cid = COND #( WHEN operation = if_abap_behv=>op-m-create THEN entity-%cid_ref )
*                                  %is_draft = entity-%is_draft
*                                  %msg = NEW /dmo/cm_flight_messages(
*                                                                      textid                = VALUE #(
*                                                                      msgid = 'SY'
*                                                                      msgno = 499
*                                                                      attr1 = 'The country codes for agency and customer not matching'
*                                                                       )
*                                                                      agency_id             = entity-AgencyId
*                                                                      customer_id           = entity-CustomerId
*                                                                      severity  = if_abap_behv_message=>severity-error
*                                                                      )
*                                  %element-agencyid = if_abap_behv=>mk-on
*          ) TO reported.

*      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD closeClaim.
    ""Perform the change of BO instance to change status
    MODIFY ENTITIES OF zmw_r_claim in local mode
        ENTITY claim
            UPDATE FIELDS ( Status )
            WITH VALUE #( for key in keys ( %tky = key-%tky
                                                        %is_draft = key-%is_draft
                                                        Status = 'C'
             )  ).
    ""Read the BO instance on which we want to make the changes
    READ ENTITIES OF zmw_r_claim in local mode
        ENTITY Claim
            ALL FIELDS
                WITH CORRESPONDING #( keys )
                    RESULT data(lt_results).

    result = value #( for Claim in lt_results ( %tky = claim-%tky
                                                          %param = claim
    ) ).

  ENDMETHOD.

  METHOD rejectClaim.
    ""Perform the change of BO instance to change status
    MODIFY ENTITIES OF zmw_r_claim in local mode
        ENTITY claim
            UPDATE FIELDS ( Status )
            WITH VALUE #( for key in keys ( %tky = key-%tky
                                                        %is_draft = key-%is_draft
                                                        Status = 'N'
             )  ).
    ""Read the BO instance on which we want to make the changes
    READ ENTITIES OF zmw_r_claim  in local mode
        ENTITY Claim
            ALL FIELDS
                WITH CORRESPONDING #( keys )
                    RESULT data(lt_results).

    result = value #( for Claim in lt_results ( %tky = claim-%tky
                                                          %param = claim
    ) ).

  ENDMETHOD.

ENDCLASS.
