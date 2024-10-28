//@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Root'
//@Metadata.ignorePropagatedAnnotations: true

define view entity ZMW_I_Pay  as select from zmw_pay as Pay
  association        to parent ZMW_I_Subclaim as _Subclaim on  $projection.Claim    = _Subclaim.Claim
                                                           and $projection.Subclaim = _Subclaim.Subclaim
  association [1..1] to ZMW_R_CLAIM           as _Claim    on  $projection.Claim = _Claim.Claim
  association [1..1] to ZMW_I_Paystat         as _Paystat  on  $projection.PayStat = _Paystat.Paystat
  association [1..1] to I_Currency            as _Currency on  $projection.CurrencyCode = _Currency.Currency
{
  key claim                 as Claim,
  key subclaim              as Subclaim,
  key payment               as Payment,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      pampaid               as Pampaid,
      currency_code         as CurrencyCode,
      bentype               as Bentype,
      pay_stat              as PayStat,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Claim,
      _Subclaim,
      _Paystat,
      _Currency
}
