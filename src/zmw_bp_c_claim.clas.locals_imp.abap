CLASS lhc_Claim DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE Claim.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Claim.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE Claim.

ENDCLASS.

CLASS lhc_Claim IMPLEMENTATION.

  METHOD augment_create.


      data: claim_create type table for create zmw_r_claim.

     claim_create = CORRESPONDING #( entities ).

     loop at claim_create assigning field-symbol(<claim>).

        <claim>-Status = 'O'.

        <claim>-%control-Status = if_abap_behv=>mk-on.

     ENDLOOP.

     MODIFY augmenting entities of zmw_r_claim
     entity claim
     create from claim_create.



  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

  METHOD precheck_update.
  ENDMETHOD.

ENDCLASS.
