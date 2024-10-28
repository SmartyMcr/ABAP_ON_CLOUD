@EndUserText.label: 'Abstract Entity for Claim Days '
define abstract entity ZMW_A_DAYSTOCLAIM
{

  initial_days_to_claim   : abap.int4;
  remaining_days_to_claim : abap.int4;
  subcl_status_indicator  : abap.int4;
  days_to_claim_indicator : abap.int4;


}
