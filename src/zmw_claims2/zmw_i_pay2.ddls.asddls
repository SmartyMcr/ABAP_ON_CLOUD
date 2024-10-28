@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment2 View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_I_PAY2
  as select from zmw_pay as Pay2
//  association        to parent ZMW_I_Subclaim2 as _Subclaim2 on  $projection.Claim    = _Subclaim2.Claim
//                                                             and $projection.Subclaim = _Subclaim2.Subclaim
//  association [1..1] to ZR_MW_CLAIM2           as _Claim2    on  $projection.Claim = _Claim2.Claim
  association [1..1] to ZMW_I_Paystat          as _Paystat   on  $projection.PayStat = _Paystat.Paystat
  association [1..1] to I_Currency             as _Currency  on  $projection.CurrencyCode = _Currency.Currency
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
//      _Claim2,
//      _Subclaim2,
      _Paystat,
      _Currency
}
