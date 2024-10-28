@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PAY2 Projection View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_C_PAY2 as select from ZMW_I_PAY2
{
    key Claim,
    key Subclaim,
    key Payment,
    Pampaid,
    CurrencyCode,
    Bentype,
    PayStat,
    CreatedBy,
    CreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
//  _Claim2,
    _Currency,
    _Paystat
//    _Subclaim2
}
