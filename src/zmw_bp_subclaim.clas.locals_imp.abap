CLASS lhc_subclaim DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_pay FOR NUMBERING
      IMPORTING entities FOR CREATE Subclaim\_Pay.
    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Subclaim~calculateTotalPrice.
*    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR Booking~calculateTotalPrice.

ENDCLASS.

CLASS lhc_subclaim IMPLEMENTATION.

  METHOD earlynumbering_cba_pay.

    DATA max_booking_pay TYPE zmw_pay-payment.

    ""Step 1: get all the travel requests and their booking data
    READ ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY Subclaim BY \_Pay
        FROM CORRESPONDING #( entities )
        LINK DATA(payments).

    ""Loop at unique travel ids
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<pay_group>) GROUP BY <pay_group>-%tky.
      ""Step 2: get the highest booking supplement number which is already there
      LOOP AT payments INTO DATA(ls_pay)
          WHERE source-Claim = <pay_group>-Claim AND
                source-Subclaim = <pay_group>-Subclaim.
        ""While comparing with ID we need Supplement ID comparision
        IF max_booking_pay < ls_pay-target-payment.
          max_booking_pay = ls_pay-target-payment.
        ENDIF.
      ENDLOOP.
      ""Step 3: get the asigned booking supplement numbers for incoming request
      LOOP AT entities INTO DATA(ls_entity)
          WHERE Claim = <pay_group>-Claim AND
                Subclaim = <pay_group>-Subclaim.
        LOOP AT ls_entity-%target INTO DATA(ls_target).
          ""While comparing with ID we need Supplement ID comparision
          IF max_booking_pay < ls_target-payment.
            max_booking_pay = ls_target-payment.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      ""Step 4: loop over all the entities of travel with same travel id
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<subclaim>)
          WHERE Claim = <pay_group>-Claim AND
                                 Subclaim = <pay_group>-subclaim.
        ""Step 5: assign new booking IDs to the booking entity inside each travel
        LOOP AT <subclaim>-%target ASSIGNING FIELD-SYMBOL(<pay_wo_numbers>).
          APPEND CORRESPONDING #( <pay_wo_numbers> ) TO mapped-pay
          ASSIGNING FIELD-SYMBOL(<mapped_pay>).
          IF <mapped_pay>-Payment IS INITIAL.
            max_booking_pay += 1.
*                     TODO WHEN DRAFT
            <mapped_pay>-%is_draft = <pay_wo_numbers>-%is_draft.
            <mapped_pay>-payment = max_booking_pay.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.


  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA claim_ids TYPE STANDARD TABLE OF zmw_c_claim WITH UNIQUE HASHED KEY key COMPONENTS claim.

    claim_ids = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING claim = claim ).

    MODIFY ENTITIES OF zmw_r_claim IN LOCAL MODE
        ENTITY Claim
        EXECUTE reCalcTotalPrice
        FROM CORRESPONDING #( claim_ids ).


  ENDMETHOD.

ENDCLASS.
