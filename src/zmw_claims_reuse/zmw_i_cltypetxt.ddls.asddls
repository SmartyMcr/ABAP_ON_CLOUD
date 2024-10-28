@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Claim Type Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_I_CLTYPETXT as select from zmw_cltype_txt
  association [1..1] to ZMW_I_CLTYPE as _Cltype on $projection.Cltype = _Cltype.Clmtype
{
    key cltype as Cltype,
    key language as Language,
    text as Text,
    
    _Cltype
    
}
