CLASS lhc_Subclaim2 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

  CONSTANTS:
  "booking status
  BEGIN OF claim_status,
    closed   TYPE c LENGTH 1 VALUE 'C', "New
    open     TYPE c LENGTH 1 VALUE 'O', "Open
    noclaim  TYPE c LENGTH 1 VALUE 'N', "No-Claim
  END OF claim_status.

    METHODS getDaysToClaim FOR READ
      IMPORTING keys FOR FUNCTION Subclaim2~getDaysToClaim RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Subclaim2~calculateTotalPrice.

*    METHODS recalcTotalPrice FOR MODIFY
*      IMPORTING keys FOR ACTION Claim2~recalcTotalPrice.

    METHODS setInitialSubclValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Subclaim2~setInitialSubclValues.

    METHODS validateSubclaimStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Subclaim2~validateSubclaimStatus.

ENDCLASS.

CLASS lhc_Subclaim2 IMPLEMENTATION.

  METHOD getDaysToClaim.

      DATA:
      c_subclaim_entity TYPE zmw_c_SUBCLAIM2,
      subclaims_result  TYPE TABLE FOR FUNCTION RESULT zr_mw_claim2\\subclaim2~getDaysToClaim,
      subclaim_result   LIKE LINE OF subclaims_result.

    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
       ENTITY subclaim2
         FIELDS ( Claim Status Opendate )
*         ALL FIELDS
         WITH CORRESPONDING #( keys )
       RESULT DATA(lt_subclaims).

    LOOP AT lt_subclaims ASSIGNING FIELD-SYMBOL(<subclaim>).
      c_subclaim_entity = CORRESPONDING #( <subclaim> ).
      "set relevant transfered data
      subclaim_result   = CORRESPONDING #( <subclaim> ).
      "calculate virtual elements
      subclaim_result-%param
        = CORRESPONDING #( zcl_mw_calc_subclaim_elem=>calculate_subclaim_status_ind( c_subclaim_entity )
                           MAPPING subcl_status_indicator = SubclaimStatusIndicator
                                   days_to_claim_indicator = DaysOpen
                                   initial_days_to_claim   = DaysToEnd
                                   remaining_days_to_claim = RemainingDays ).
      "append
      APPEND subclaim_result TO subclaims_result.
    ENDLOOP.

    result = subclaims_result.



  ENDMETHOD.


  METHOD calculateTotalPrice.
    " Read all parent IDs
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Subclaim2 BY \_Claim2
        FIELDS ( Claim  )
        WITH CORRESPONDING #(  keys  )
      RESULT DATA(LT_Claims).

    " Trigger Re-Calculation on Root Node
    MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Claim2
        EXECUTE reCalctotalprice
          FROM CORRESPONDING  #( LT_Claims ).
  ENDMETHOD.

  METHOD setInitialSubclValues.

    "Read all travels for the requested subclaims
    " If multiple subclaims of the same claim are requested, the claim is returned only once.
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Subclaim2 BY \_Claim2
        FIELDS ( Claim )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_claims) LINK DATA(subclaim_to_claim).

    "Read all bookings
    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Subclaim2
        FIELDS ( Claim Subclaim OpenDate )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_subclaims).

    DATA: update TYPE TABLE FOR UPDATE zr_mw_claim2\\Subclaim2.
    update = CORRESPONDING #( lt_subclaims ).
    DELETE update WHERE Claim IS NOT INITIAL AND OpenDate IS NOT INITIAL AND Status IS NOT INITIAL.

    LOOP AT update ASSIGNING FIELD-SYMBOL(<update>).
      IF <update>-Claim IS INITIAL.
        <update>-Claim = lt_claims[ KEY id %tky = subclaim_to_claim[ KEY id source-%tky = <update>-%tky ]-target-%tky ]-Claim.
        <update>-%control-Claim = if_abap_behv=>mk-on.
      ENDIF.

      IF <update>-OpenDate IS INITIAL.
        <update>-OpenDate = cl_abap_context_info=>get_system_date( ).
        <update>-%control-OpenDate = if_abap_behv=>mk-on.
      ENDIF.

      IF <update>-Status IS INITIAL.
        <update>-Status = 'O'.
        <update>-%control-Status = if_abap_behv=>mk-on.
      ENDIF.
    ENDLOOP.

    IF update IS NOT INITIAL.
      MODIFY ENTITIES OF zr_mw_claim2 IN LOCAL MODE
      ENTITY Subclaim2
        UPDATE FROM update.
    ENDIF.

  ENDMETHOD.

  METHOD validateSubclaimStatus.


    READ ENTITIES OF zr_mw_claim2 IN LOCAL MODE
     ENTITY subclaim2
       FIELDS ( Status )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_subclaims).

    LOOP AT Lt_subclaims INTO DATA(ls_subclaim).
      CASE ls_subclaim-Status.
        WHEN 'O' OR 'C' OR 'N'.      " New
        WHEN OTHERS.
          APPEND VALUE #( %tky = ls_subclaim-%tky ) TO failed-subclaim2.
          APPEND VALUE #( %tky = ls_subclaim-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid      = /dmo/cm_flight_messages=>status_invalid
                                     status      = ls_subclaim-Status
                                     severity    = if_abap_behv_message=>severity-error )
                          %element-Status = if_abap_behv=>mk-on
                          %path = VALUE #( claim2-claim    = ls_subclaim-claim )
                        ) TO reported-subclaim2.
      ENDCASE.
    ENDLOOP.




  ENDMETHOD.

ENDCLASS.
