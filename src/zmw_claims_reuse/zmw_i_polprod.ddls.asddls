@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Policy Product CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS  //Prevents pop up box appearing 
define view entity ZMW_I_POLPROD
  as select from zmw_polprod_t
  association [0..*] to ZMW_I_POLPROD_T as _Text on $projection.Polprod = _Text.PolProd

{
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{importance: #HIGH}]
      @ObjectModel.text.association: '_Text'
  key polprod as Polprod,


      _Text

}
