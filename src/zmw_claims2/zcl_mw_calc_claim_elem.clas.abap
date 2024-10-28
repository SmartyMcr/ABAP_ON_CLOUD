CLASS zcl_mw_calc_claim_elem DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
    CLASS-METHODS:
      calculate_claim_status_ind
        IMPORTING is_original_data TYPE zc_mw_claim2
        RETURNING VALUE(result)    TYPE zc_mw_claim2.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mw_calc_claim_elem IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.

    IF it_requested_calc_elements IS INITIAL.
      EXIT.
    ENDIF.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elements>).
      CASE <fs_req_calc_elements>.
          "virtual elements from TRAVEL entity

        WHEN 'OVERALLSTATUSINDICATOR'.

          DATA lt_claim_original_data TYPE STANDARD TABLE OF zc_mw_claim2 WITH DEFAULT KEY.
          lt_claim_original_data = CORRESPONDING #( it_original_data ).
          LOOP AT lt_claim_original_data ASSIGNING FIELD-SYMBOL(<fs_claim_original_data>).

******* MW   This now calls the custom method below
*            <fs_claim_original_data> = calculate_claim_status_ind( <fs_claim_original_data> ).
            <fs_claim_original_data> = zcl_mw_calc_claim_elem=>calculate_claim_status_ind( <fs_claim_original_data> ).

          ENDLOOP.

          ct_calculated_data = CORRESPONDING #( lt_claim_original_data ).

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    IF iv_entity EQ 'ZC_MW_CLAIM2'. "Claim BO node
      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_claim_calc_element>).
        CASE <fs_claim_calc_element>.
          WHEN 'OVERALLSTATUSINDICATOR'.
            APPEND 'STATUS' TO et_requested_orig_elements.
        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_claim_status_ind.

    result = CORRESPONDING #( is_original_data ).
    "travel status indicator
    "(criticality: 1  = red | 2 = orange  | 3 = green)
    CASE result-Status.
      WHEN 'N'.
        result-OverallStatusIndicator = 1.
      WHEN 'O'.
        result-OverallStatusIndicator = 2.
      WHEN 'C'.
        result-OverallStatusIndicator = 3.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
