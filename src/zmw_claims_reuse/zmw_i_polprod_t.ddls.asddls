@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Policy Product CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_I_POLPROD_T
  as select from zmw_polprod_txt
  association [1..1] to ZMW_I_POLPROD as _OverallPolProd on $projection.PolProd = _OverallPolProd.Polprod
{

      @ObjectModel.text.element: ['Text']
  key polprod  as PolProd,
      @Semantics.language: true
  key language as Language,

      @Semantics.text: true
      text     as Text,

      _OverallPolProd
}
