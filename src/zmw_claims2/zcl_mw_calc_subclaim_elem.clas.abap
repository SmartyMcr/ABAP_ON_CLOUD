CLASS zcl_mw_calc_subclaim_elem DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read .
    CLASS-METHODS:
      calculate_subclaim_status_ind
        IMPORTING is_original_data TYPE zmw_c_subclaim2
        RETURNING VALUE(result)    TYPE zmw_c_subclaim2.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mw_calc_subclaim_elem IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.

    IF it_requested_calc_elements IS INITIAL.
      EXIT.
    ENDIF.

    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_req_calc_elements>).
      CASE <fs_req_calc_elements>.
          "virtual elements from TRAVEL entity

        WHEN 'SUBCLAIMSTATUSINDICATOR' OR 'DAYSOPEN' OR 'REMAININGDAYS' OR 'DAYSTOEND'.

          DATA lt_subclaim_original_data TYPE STANDARD TABLE OF zmw_c_subclaim2 WITH DEFAULT KEY.
          lt_subclaim_original_data = CORRESPONDING #( it_original_data ).
          LOOP AT lt_subclaim_original_data ASSIGNING FIELD-SYMBOL(<fs_subclaim_original_data>).
            <fs_subclaim_original_data> = zcl_mw_calc_subclaim_elem=>calculate_subclaim_status_ind( <fs_subclaim_original_data> ).
          ENDLOOP.
          ct_calculated_data = CORRESPONDING #( lt_subclaim_original_data ).

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity EQ 'ZMW_C_SUBCLAIM2'. "SubClaim BO node
      LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_subclaim_calc_element>).
        CASE <fs_subclaim_calc_element>.
          WHEN 'SUBCLAIMSTATUSINDICATOR'.
            COLLECT `STATUS` INTO et_requested_orig_elements.
          WHEN 'DAYSOPEN'.
            COLLECT `OPENDATE` INTO et_requested_orig_elements.
          WHEN 'REMAININGDAYS'.
            COLLECT `OPENDATE` INTO et_requested_orig_elements.
          WHEN 'DAYSTOEND'.
            COLLECT `OPENDATE` INTO et_requested_orig_elements.

        ENDCASE.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD calculate_subclaim_status_ind.

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    result = CORRESPONDING #( is_original_data ).

    "VE InitialDaysToFlight: initial days to flight
    DATA(open_days) = result-Opendate - today.
    open_days += 5.
    IF open_days > 0 AND open_days < 999.
      result-DaysOpen =  open_days.
    ELSE.
      result-DaysOpen = 33.
    ENDIF.

    "VE RemainingDaysToFlight: remaining days to flight
    DATA(remaining_days) = result-Opendate - today.
    IF remaining_days < 0 OR remaining_days > 999.
      result-RemainingDays = 44.
    ELSE.
      result-RemainingDays =  result-Opendate - today.
    ENDIF.

    "VE DaysToFlightIndicator: remaining days to flight *indicator*
    "(dataPoint: 1 = red | 2 = orange | 3 = green | 4 = grey | 5 = bleu)
    IF remaining_days >= 6.
      result-DaysToEnd = 3.       "green
    ELSEIF remaining_days <= 5 AND remaining_days >= 3.
      result-DaysToEnd = 2.       "orange
    ELSEIF remaining_days <= 2 AND remaining_days >= 0.
      result-DaysToEnd = 1.       "red
    ELSE.
      result-DaysToEnd = 4.       "grey
    ENDIF.

    "VE BookingStatusIndicator: booking status indicator
    "(criticality: 1  = red | 2 = orange  | 3 = green)
    CASE result-Status.
      WHEN 'X'.
        result-SubclaimStatusIndicator = 1.
      WHEN 'N'.
        result-SubclaimStatusIndicator = 2.
      WHEN 'B'.
        result-SubclaimStatusIndicator = 3.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
