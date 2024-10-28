CLASS lsc_ZR_MW_CLAIM2 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_MW_CLAIM2 IMPLEMENTATION.

  METHOD adjust_numbers.


    DATA: claim_id_max TYPE zmw_claim-claim.

    "Root BO entity: Travel
    IF mapped-claim2 IS NOT INITIAL.
      TRY.
          "get numbers
          cl_numberrange_runtime=>number_get(
            EXPORTING
              nr_range_nr       = '01'
              object            = '/DMO/TRV_M'  "Fallback: '/DMO/TRV_M'
              quantity          = CONV #( lines( mapped-claim2 ) )
            IMPORTING
              number            = DATA(number_range_key)
              returncode        = DATA(number_range_return_code)
              returned_quantity = DATA(number_range_returned_quantity)
          ).
        CATCH cx_number_ranges INTO DATA(lx_number_ranges).
          RAISE SHORTDUMP TYPE cx_number_ranges
            EXPORTING
              previous = lx_number_ranges.
      ENDTRY.

*  Mart - Alternate - just get the last claim number and add 1 ----------
      SELECT MAX( claim ) FROM zmw_claim INTO @DATA(lv_claim).

      ASSERT number_range_returned_quantity = lines( mapped-claim2 ).
      claim_id_max = number_range_key - number_range_returned_quantity.
      LOOP AT mapped-claim2 ASSIGNING FIELD-SYMBOL(<claim>).
        claim_id_max += 1.
        <claim>-Claim = claim_id_max.
        SHIFT <claim>-Claim LEFT DELETING LEADING ''.
      ENDLOOP.
    ENDIF.



    "Child BO entity: Subclaim
    IF mapped-subclaim2 IS NOT INITIAL.
      READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
        ENTITY Subclaim2 BY \_Claim2
          FROM VALUE #( FOR Subclaim2 IN mapped-subclaim2 WHERE ( %tmp-Claim IS INITIAL )
                                                            ( %pid = subclaim2-%pid
                                                              %key = subclaim2-%tmp ) )
        LINK DATA(subclaim2_to_claim2_links).

      LOOP AT mapped-subclaim2 ASSIGNING FIELD-SYMBOL(<subclaim2>).
        <subclaim2>-Claim =
          COND #( WHEN <Subclaim2>-%tmp-Claim IS INITIAL
                  THEN mapped-Claim2[ %pid = subclaim2_to_claim2_links[ source-%pid = <subclaim2>-%pid ]-target-%pid ]-Claim
                  ELSE <subclaim2>-%tmp-Claim ).
      ENDLOOP.

      LOOP AT mapped-subclaim2 INTO DATA(mapped_subclaim2) GROUP BY mapped_Subclaim2-Claim.
        SELECT MAX( Subclaim ) FROM zmw_subclaim WHERE Claim = @mapped_subclaim2-Claim INTO @DATA(max_subclaim_id) .
        LOOP AT GROUP mapped_subclaim2 ASSIGNING <subclaim2>.
          max_subclaim_id += 1.
          <subclaim2>-Subclaim = max_subclaim_id.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.


CLASS lhc_Claim2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Claim2 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Claim2 RESULT result.

    METHODS closeClaim FOR MODIFY
      IMPORTING keys FOR ACTION Claim2~closeClaim RESULT result.

    METHODS recalcTotalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Claim2~recalcTotalPrice.

    METHODS rejectClaim FOR MODIFY
      IMPORTING keys FOR ACTION Claim2~rejectClaim RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Claim2~calculateTotalPrice.

    METHODS setInitialClaimValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Claim2~setInitialClaimValues.

    METHODS validateClmtype FOR VALIDATE ON SAVE
      IMPORTING keys FOR Claim2~validateClmtype.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Claim2~validateDates.

    METHODS validatePolprod FOR VALIDATE ON SAVE
      IMPORTING keys FOR Claim2~validatePolprod.

    METHODS createClaim FOR MODIFY
      IMPORTING keys FOR ACTION Claim2~createClaim.

ENDCLASS.

CLASS lhc_Claim2 IMPLEMENTATION.

  METHOD get_instance_features.

**************************************************************************
* Instance-bound dynamic feature control
**************************************************************************
    " read relevant travel instance data
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY claim2
         FIELDS ( claim Status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_claims)
       FAILED failed.

    " evaluate the conditions, set the operation state, and set result parameter
    result = VALUE #( FOR claim IN lt_claims
                       ( %tky                   = claim-%tky

                         %features-%update      = COND #( WHEN claim-Status = 'N'
                                                          THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )

                         %features-%delete      = COND #( WHEN claim-Status = 'O'
                                                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled   )

                         %action-Edit           = COND #( WHEN claim-Status = 'N'
                                                            THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )

                         %action-closeClaim   = COND #( WHEN claim-Status = 'C'
                                                              THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )

                         %action-rejectClaim   = COND #( WHEN claim-Status = 'N'
                                                            THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled   )
                      ) ).

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

METHOD closeClaim.


**************************************************************************
* Instance-bound action acceptTravel
**************************************************************************

    MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
         ENTITY claim2
            UPDATE FIELDS ( Status )
               WITH VALUE #( FOR key IN keys ( %tky         = key-%tky
                                               Status = 'C' ) ). " 'C' - Closed

    " read changed data for result
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY claim2
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(claims).

    result = VALUE #( FOR claim IN claims ( %tky = claim-%tky  %param = claim ) ).


  ENDMETHOD.

  METHOD rejectClaim.
    MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
         ENTITY claim2
            UPDATE FIELDS ( Status )
               WITH VALUE #( FOR key IN keys ( %tky         = key-%tky
                                               Status = 'N' ) ). " 'N' - No Claim

    " read changed data for result
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY claim2
         ALL FIELDS WITH
         CORRESPONDING #( keys )
       RESULT DATA(claims).

    result = VALUE #( FOR claim IN claims ( %tky = claim-%tky  %param = claim ) ).

  ENDMETHOD.

  METHOD reCalctotalprice.


    TYPES: BEGIN OF ty_amount_per_currencycode,
             amount        TYPE /dmo/total_price,
             currency_code TYPE /dmo/currency_code,
           END OF ty_amount_per_currencycode.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currencycode.

    " Read all relevant travel instances.
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
         ENTITY Claim2
            FIELDS ( BookingFee CurrencyCode )
            WITH CORRESPONDING #( keys )
         RESULT DATA(claims).

    DELETE claims WHERE CurrencyCode IS INITIAL.

    " Read all associated bookings and add them to the total price.
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Claim2 BY \_Subclaim2
        FIELDS ( TotalPaid CurrencyCode )
      WITH CORRESPONDING #( claims )
      LINK DATA(subclaim_links)
      RESULT DATA(subclaims).

    LOOP AT claims ASSIGNING FIELD-SYMBOL(<claim>).
      " Set the start for the calculation by adding the booking fee.
      amounts_per_currencycode = VALUE #( ( amount        = <claim>-Bookingfee
                                            currency_code = <claim>-currencycode ) ).

      LOOP AT subclaim_links INTO DATA(subclaim_link) USING KEY id WHERE source-%tky = <claim>-%tky.
        " Short dump occurs if link table does not match read table, which must never happen
        DATA(subclaim) = subclaims[ KEY id  %tky = subclaim_link-target-%tky ].
        COLLECT VALUE ty_amount_per_currencycode( amount        = subclaim-TotalPaid
                                                  currency_code = subclaim-CurrencyCode ) INTO amounts_per_currencycode.
      ENDLOOP.

      DELETE amounts_per_currencycode WHERE currency_code IS INITIAL.

      CLEAR <claim>-Totalprice.
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).
        " If needed do a Currency Conversion
        IF amount_per_currencycode-currency_code = <claim>-CurrencyCode.
          <claim>-TotalPrice += amount_per_currencycode-amount.
        ELSE.
          /dmo/cl_flight_amdp=>convert_currency(
             EXPORTING
               iv_amount                   =  amount_per_currencycode-amount
               iv_currency_code_source     =  amount_per_currencycode-currency_code
               iv_currency_code_target     =  <claim>-CurrencyCode
               iv_exchange_rate_date       =  cl_abap_context_info=>get_system_date( )
             IMPORTING
               ev_amount                   = DATA(total_booking_price_per_curr)
            ).
          <claim>-TotalPrice += total_booking_price_per_curr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    " write back the modified total_price of travels
    MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY claim2
        UPDATE FIELDS ( TotalPrice )
        WITH CORRESPONDING #( claims ).



  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Claim2
        EXECUTE reCalcTotalPrice
        FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD setInitialClaimValues.

    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
    ENTITY Claim2
      FIELDS ( Status Opendate CurrencyCode )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_claims).

    DATA: update TYPE TABLE FOR UPDATE zr_mw_claim2\\claim2.
    update = CORRESPONDING #( lt_claims ).
    DELETE update WHERE Opendate IS NOT INITIAL "AND EndDate IS NOT INITIAL
                    AND CurrencyCode IS NOT INITIAL AND Status IS NOT INITIAL.

    LOOP AT update ASSIGNING FIELD-SYMBOL(<update>).
      IF <update>-OpenDate IS INITIAL.
        <update>-OpenDate     = cl_abap_context_info=>get_system_date( ) + 1.
        <update>-%control-OpenDate = if_abap_behv=>mk-on.
      ENDIF.
*      IF <update>-EndDate  IS INITIAL.
*        <update>-EndDate       = cl_abap_context_info=>get_system_date( ) + 15.
*        <update>-%control-EndDate = if_abap_behv=>mk-on.
*      ENDIF.
      IF <update>-CurrencyCode IS INITIAL.
        <update>-CurrencyCode  = 'EUR'.
        <update>-%control-CurrencyCode = if_abap_behv=>mk-on.
      ENDIF.
      IF <update>-Status IS INITIAL.
        <update>-Status = 'O'.
        <update>-%control-Status = if_abap_behv=>mk-on.
      ENDIF.
    ENDLOOP.

    IF update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Claim2
        UPDATE FROM update.
    ENDIF.

  ENDMETHOD.

  METHOD validateClmtype.

    "read relevant travel instance data
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
    ENTITY Claim2
     FIELDS ( Clmtype )
     WITH CORRESPONDING #( keys )
    RESULT DATA(claims).

    DATA clmtypes TYPE SORTED TABLE OF ZMW_I_cltype WITH UNIQUE KEY Clmtype.

    "optimization of DB select: extract distinct non-initial customer IDs
    clmtypes = CORRESPONDING #( claims DISCARDING DUPLICATES MAPPING clmtype = clmtype EXCEPT * ).
    DELETE clmtypes WHERE clmtype IS INITIAL.

    IF clmtypes IS NOT INITIAL.
      "check if customer ID exists
      SELECT FROM ZMW_I_cltype FIELDS clmtype
                                FOR ALL ENTRIES IN @clmtypes
                                WHERE clmtype = @clmtypes-clmtype
        INTO TABLE @DATA(valid_clmtypes).
    ENDIF.

    "raise msg for non existing and initial customer id
    LOOP AT claims INTO DATA(claim).
      APPEND VALUE #(  %tky        = claim-%tky
                       %state_area = 'VALIDATE_CLMTYPE'
                     ) TO reported-claim2.

      IF claim-Clmtype IS  INITIAL.
        APPEND VALUE #( %tky = claim-%tky ) TO failed-claim2.

        APPEND VALUE #( %tky        = claim-%tky
                        %state_area = 'VALIDATE_CLMTYPE'
                        %msg        = NEW /dmo/cm_flight_messages(
                                        textid   = /dmo/cm_flight_messages=>status_invalid
                                        severity = if_abap_behv_message=>severity-error )
                        %element-clmtype = if_abap_behv=>mk-on
                      ) TO reported-claim2.

      ELSEIF claim-clmtype IS NOT INITIAL AND NOT line_exists( valid_clmtypes[ clmtype = claim-clmtype ] ).
        APPEND VALUE #(  %tky = claim-%tky ) TO failed-claim2.

        APPEND VALUE #(  %tky        = claim-%tky
                         %state_area = 'VALIDATE_CLMTYPE'
                         %msg        = NEW /dmo/cm_flight_messages(
                                         customer_id = CONV #( claim-clmtype )
                                         textid      = /dmo/cm_flight_messages=>customer_unkown
                                         severity    = if_abap_behv_message=>severity-error )
                         %element-clmtype = if_abap_behv=>mk-on
                      ) TO reported-claim2.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
     ENTITY claim2
       FIELDS ( lossdate opendate )
       WITH CORRESPONDING #( keys )
     RESULT DATA(claims).

    LOOP AT claims INTO DATA(claim).
      APPEND VALUE #(  %tky        = claim-%tky
                       %state_area = 'VALIDATE_DATES' ) TO reported-claim2.

      IF claim-openDate < claim-lossdate.                                 "end_date before begin_date
        APPEND VALUE #( %tky = claim-%tky ) TO failed-claim2.
        APPEND VALUE #( %tky = claim-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = claim-opendate
                                   end_date   = claim-lossdate
                                   travel_id  = CONV #(  claim-claim ) )
                        %element-lossdate    = if_abap_behv=>mk-on
                        %element-opendate      = if_abap_behv=>mk-on
                     ) TO reported-claim2.

      ELSEIF claim-opendate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future
        APPEND VALUE #( %tky        = claim-%tky ) TO failed-claim2.
        APPEND VALUE #( %tky = claim-%tky
                        %state_area = 'VALIDATE_DATES'
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-lossdate  = if_abap_behv=>mk-on
                        %element-opendate    = if_abap_behv=>mk-on
                      ) TO reported-claim2.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validatePolprod.

    "read relevant travel instance data
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
    ENTITY Claim2
     FIELDS ( Polprod )
     WITH CORRESPONDING #( keys )
    RESULT DATA(claims).

    DATA polprods TYPE SORTED TABLE OF zmw_i_polprod WITH UNIQUE KEY polprod.

    "optimization of DB select: extract distinct non-initial customer IDs
    polprods = CORRESPONDING #( claims DISCARDING DUPLICATES MAPPING Polprod = Polprod EXCEPT * ).
    DELETE polprods WHERE polprod IS INITIAL.

    IF polprods IS NOT INITIAL.
      "check if customer ID exists
      SELECT FROM zmw_i_polprod FIELDS polprod
                                FOR ALL ENTRIES IN @polprods
                                WHERE polprod = @polprods-polprod
        INTO TABLE @DATA(valid_polprods).
    ENDIF.

    "raise msg for non existing and initial customer id
    LOOP AT claims INTO DATA(claim).
      APPEND VALUE #(  %tky        = claim-%tky
                       %state_area = 'VALIDATE_POLPROD'
                     ) TO reported-claim2.

      IF claim-polprod IS  INITIAL.
        APPEND VALUE #( %tky = claim-%tky ) TO failed-claim2.

        APPEND VALUE #( %tky        = claim-%tky
                        %state_area = 'VALIDATE_POLPROD'
                        %msg        = NEW /dmo/cm_flight_messages(
                                        textid   = /dmo/cm_flight_messages=>status_invalid
                                        severity = if_abap_behv_message=>severity-error )
                        %element-polprod = if_abap_behv=>mk-on
                      ) TO reported-claim2.

      ELSEIF claim-polprod IS NOT INITIAL AND NOT line_exists( valid_polprods[ polprod = claim-polprod ] ).
        APPEND VALUE #(  %tky = claim-%tky ) TO failed-claim2.

        APPEND VALUE #(  %tky        = claim-%tky
                         %state_area = 'VALIDATE_POLPROD'
                         %msg        = NEW /dmo/cm_flight_messages(
                                         customer_id = CONV #( claim-polprod )
                                         textid      = /dmo/cm_flight_messages=>customer_unkown
                                         severity    = if_abap_behv_message=>severity-error )
                         %element-Polprod = if_abap_behv=>mk-on
                      ) TO reported-claim2.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.




  METHOD createClaim.

    IF keys IS NOT INITIAL.
*
*      SELECT * FROM /dmo/flight FOR ALL ENTRIES IN @keys WHERE carrier_id    = @keys-%param-carrier_id
*                                                         AND   connection_id = @keys-%param-connection_id
*                                                         AND   flight_date   = @keys-%param-flight_date
*                                                         INTO TABLE @DATA(flights).

      SELECT * FROM zmw_i_polprod FOR ALL ENTRIES IN @keys WHERE polprod = @keys-%param-polprod INTO TABLE @DATA(lt_polprod).
      SELECT * FROM zmw_i_cltype FOR ALL ENTRIES IN @keys WHERE clmtype = @keys-%param-Clmtype INTO TABLE @DATA(lt_clmtype).

      "create travel instances with default Claims
      MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
        ENTITY Claim2
          CREATE
            FIELDS ( Polprod Clmtype ClaimDesc )
              WITH VALUE #( FOR key IN keys ( %cid = key-%cid
                                              %is_draft = key-%param-%is_draft
                                              polprod    = key-%param-polprod
                                              clmtype    = key-%param-clmtype
                                              ClaimDesc = 'Own Claim Create Implementation' ) )
*          CREATE BY \_Subclaim2
*            FIELDS ( Claim CarrierID ConnectionID FlightDate FlightPrice CurrencyCode )
*              WITH VALUE #( FOR key IN keys INDEX INTO i
*                          ( %cid_ref  = key-%cid
*                            %is_draft = key-%param-%is_draft
*                            %target   = VALUE #( ( %cid         = i
*                                                   %is_draft    = key-%param-%is_draft
*                                                   CustomerID   = key-%param-customer_id
*                                                   CarrierID    = key-%param-carrier_id
*                                                   ConnectionID = key-%param-connection_id
*                                                   FlightDate   = key-%param-flight_date
*                                                   FlightPrice  = VALUE #( flights[ carrier_id    = key-%param-carrier_id
*                                                                                    connection_id = key-%param-connection_id
*                                                                                    flight_date   = key-%param-flight_date ]-price OPTIONAL )
*                                                   CurrencyCode = VALUE #( flights[ carrier_id    = key-%param-carrier_id
*                                                                                    connection_id = key-%param-connection_id
*                                                                                    flight_date   = key-%param-flight_date ]-currency_code OPTIONAL )
*                          ) ) ) )
      MAPPED mapped.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
