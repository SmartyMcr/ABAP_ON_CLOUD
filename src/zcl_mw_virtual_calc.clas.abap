CLASS zcl_mw_virtual_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_mw_virtual_calc IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    check not it_original_data is initial.

    data: lt_calc_data type standard table of zmw_c_claim with DEFAULT KEY,
            lv_rate type p DECIMALS 2 VALUE '0.025'.

     lt_calc_data = CORRESPONDING #( it_original_data ).

     loop at lt_calc_data ASSIGNING FIELD-SYMBOL(<fs_calc>).
        <fs_calc>-Deductable = <fs_calc>-TotalPrice * lv_rate.
        ""here you can call a BAPI and calculate some values and send those in VE
*        <fs_calc>-dayOfTheFlight = 'Sunday'.
        cl_scal_utils=>date_compute_day(
          EXPORTING
            iv_date           = <fs_calc>-OpenDate
          IMPORTING
*            ev_weekday_number =
            ev_weekday_name   = data(lv_day)
        ).
        <fs_calc>-dayOfTheClaim = lv_day.
     ENDLOOP.

     ct_calculated_data = CORRESPONDING #(  lt_calc_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
