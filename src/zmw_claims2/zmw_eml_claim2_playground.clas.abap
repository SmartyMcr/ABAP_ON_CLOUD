CLASS zmw_eml_claim2_playground DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zmw_eml_claim2_playground IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    "declare internal table using derived type
    DATA claim_keys TYPE TABLE FOR READ IMPORT zr_mw_claim2 .

    "fill in relevant travel keys for READ request
    claim_keys = VALUE #( ( Claim = '4273' )
                          "( TravelID = '...' )
                         ).

    "insert your coding here
    "read _travel_ instances for specified key
    READ ENTITIES OF zr_mw_claim2
      ENTITY Claim2
*        ALL FIELDS
       FIELDS ( Claim OpenDate LossDate )
       WITH claim_keys
   RESULT DATA(lt_claims_read)
   FAILED DATA(failed)
   REPORTED DATA(reported).

    "console output
    out->write( | ***Exercise 10: Implement the Base BO Behavior - Functions*** | ).
*    out->write( lt_travels_read ).
    IF failed IS NOT INITIAL.
      out->write( |- [ERROR] Cause for failed read: { failed-claim2[ 1 ]-%fail-cause } | ).
    ENDIF.

    "read relevant booking instances
    READ ENTITIES OF zr_mw_claim2
      ENTITY Claim2 BY \_Subclaim2
        FROM CORRESPONDING #( lt_claims_read )
        RESULT DATA(lt_subclaims_read)
    LINK DATA(claims_to_subclaims).

    "execute function getDaysToFlight
    READ ENTITIES OF zr_mw_claim2
      ENTITY Subclaim2
        EXECUTE getDaysToClaim
          FROM VALUE #( FOR link IN claims_to_subclaims ( %tky = link-target-%tky ) )
    RESULT DATA(days_to_claim).

    "output result structure
    LOOP AT days_to_claim ASSIGNING FIELD-SYMBOL(<days_to_claim>).
      out->write( | Claim = { <days_to_claim>-%tky-claim } |  ).
      out->write( | Subclaim = { <days_to_claim>-%tky-subclaim } | ).
      out->write( | RemainingDaysToClaim  = { <days_to_claim>-%param-remaining_days_to_claim } | ).
      out->write( | InitialDaysToClaim = { <days_to_claim>-%param-initial_days_to_claim } | ).
      out->write( | ---------------           | ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
