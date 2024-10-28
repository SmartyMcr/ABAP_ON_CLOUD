@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Status Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_I_PAYSTATTXT as select from zmw_paystat_txt
association [1..1] to ZMW_I_Paystat as _PayStat on $projection.Paystat = _PayStat.Paystat
{
    key paystat as Paystat,
    key language as Language,
    text as Text,
    
    _PayStat
}
