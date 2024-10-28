CLASS zmw_claim_func DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zmw_claim_func IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


** Fill the ZMW_I_CLSTATUS_T table with values
*
*    DATA lt_status TYPE STANDARD TABLE OF zmw_clstatus.
*
*    lt_status = VALUE #(  ( status = 'O' )
*                          ( status = 'C' )
*                          ( status = 'N' ) ).
*
*    INSERT zmw_clstatus FROM TABLE @lt_status.
*
*
*    DATA lt_status_t TYPE STANDARD TABLE OF zmw_clstatus_t.
*
*
*    lt_status_t = VALUE #(
*                            ( Status = 'O' Language = 'EN' Text = 'Open' )
*                            ( Status = 'C' Language = 'EN' Text = 'Closed' )
*                            ( Status = 'N' Language = 'EN' Text = 'No Claim' )
*                            ).
*
*    INSERT zmw_clstatus_t FROM TABLE @lt_status_t.

** Fill the ZMW_I_PAYSTAT_T table with values********************************
*
*    DATA lt_status TYPE STANDARD TABLE OF zmw_paystat_t.
*
*    lt_status = VALUE #(  ( paystat = 'N' )
*                          ( paystat = 'P' )
*                          ( paystat = 'A' )
*                          ( paystat = 'C' )
*                           ).
*
*    INSERT zmw_paystat_t FROM TABLE @lt_status.
*
*
*    DATA lt_status_t TYPE STANDARD TABLE OF zmw_paystat_txt.
*
*
*    lt_status_t = VALUE #(
*                            ( paystat = 'N' Language = 'E' Text = 'New' )
*                            ( paystat = 'P' Language = 'E' Text = 'Paid' )
*                            ( paystat = 'A' Language = 'E' Text = 'Approved' )
*                            ( paystat = 'C' Language = 'E' Text = 'Closed' )
*                            ).
*
*    INSERT zmw_paystat_txt FROM TABLE @lt_status_t.

** Fill the ZMW_I_POLPROD_T table with values********************************

*    DATA lt_status TYPE STANDARD TABLE OF zmw_polprod_t.
*
*    lt_status = VALUE #(  ( polprod = 'MOTOR' )
*                          ( polprod = 'LIFE' )
*                          ( polprod = 'NLIFE' )
*                          ( polprod = 'PENS' )
*                           ).
*
*    INSERT zmw_polprod_t FROM TABLE @lt_status.
*
*    DATA lt_status_t TYPE STANDARD TABLE OF zmw_polprod_txt.
*
*
*    lt_status_t = VALUE #(
*                            ( polprod = 'MOTOR'  Language = 'E' Text = 'Motor' )
*                            ( polprod = 'LIFE'   Language = 'E' Text = 'Life' )
*                            ( polprod = 'NLIFE'  Language = 'E' Text = 'Non-Life' )
*                            ( polprod = 'PENS'   Language = 'E' Text = 'Pensions' )
*                            ).
*
*    INSERT zmw_polprod_txt FROM TABLE @lt_status_t.

** Fill the ZMW_I_CLMTYPE_T table with values********************************

*    DATA lt_status TYPE STANDARD TABLE OF zmw_cltype_t.
*
*    lt_status = VALUE #(  ( clmtype = 'OWND' )
*                          ( clmtype = 'THRD' )
*                          ( clmtype = 'WIND' )
*                           ).
*
*    INSERT zmw_cltype_t FROM TABLE @lt_status.
*
*    DATA lt_status_t TYPE STANDARD TABLE OF zmw_cltype_txt.
*
*    lt_status_t = VALUE #(
*                            ( cltype = 'OWND' Language = 'E' Text = 'Own Damage' )
*                            ( cltype = 'THRD' Language = 'E' Text = 'Third Party' )
*                            ( cltype = 'WIND' Language = 'E' Text = 'Windshield' )
*                            ).
*
*    INSERT zmw_cltype_txt FROM TABLE @lt_status_t.

* Add a payment record


*    DATA ls_pay TYPE zmw_pay.
*
*    ls_pay = VALUE #( claim = '80000001' subclaim = '1'  payment = '1'  pampaid = '5000'
*                      currency_code = 'GBP' ).
*
*    delete from zmw_pay.
*    Modify zmw_pay from @ls_pay.
*
*    if sy-subrc = 0.
*
*    endif.
********************************************
DATA: lv_object   TYPE cl_numberrange_objects=>nr_attributes-object,
      lt_interval TYPE cl_numberrange_intervals=>nr_interval,
      ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.
    DATA: oref   TYPE REF TO cx_root.
    lv_object = 'ZCLAIM'.

*   intervals
    ls_interval-nrrangenr  = '01'.
    ls_interval-fromnumber = '00000001'.
    ls_interval-tonumber   = '19999999'.
    ls_interval-procind    = 'I'.
    APPEND ls_interval TO lt_interval.

    ls_interval-nrrangenr  = '02'.
    ls_interval-fromnumber = '20000000'.
    ls_interval-tonumber   = '29999999'.
    APPEND ls_interval TO lt_interval.

*   create intervals
    TRY.

        out->write( |Create Intervals for Object: { lv_object } | ).

        CALL METHOD cl_numberrange_intervals=>create
          EXPORTING
            interval  = lt_interval
            object    = lv_object
            subobject = ' '
          IMPORTING
            error     = DATA(lv_error)
            error_inf = DATA(ls_error)
            error_iv  = DATA(lt_error_iv)
            warning   = DATA(lv_warning).
        CATCH cx_root into oref.
       ENDTRY.


* create number range object for Claim
 DATA:
    lv_devclass TYPE cl_numberrange_objects=>nr_attributes-devclass,
    lv_corrnr   TYPE cl_numberrange_objects=>nr_attributes-corrnr.

    lv_object   = 'ZCLAIM'.
    lv_devclass = 'ZCLAIM'.
    lv_corrnr   = 'SIDK123456'.

    TRY.
    cl_numberrange_objects=>create(
      EXPORTING
        attributes = VALUE #( object     = lv_object
                              domlen     = 'CHAR8'
                              percentage = 5
                              buffer     = abap_true
                              noivbuffer = 10
                              devclass   = lv_devclass
                              corrnr     = lv_corrnr )
        obj_text   = VALUE #( object     = lv_object
                              langu      = 'E'
                              txt        = 'Create object'
                              txtshort   = 'Test create' )
      IMPORTING
        errors     = DATA(lt_errors)
        returncode = DATA(lv_returncode)
        ).
      CATCH cx_root into oref.

    ENDTRY.

    if sy-subrc = 0.

    endif.

     ENDMETHOD.
ENDCLASS.
