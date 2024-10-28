@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Payment Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS  //Prevents pop up box appearing 
define view entity ZMW_I_Paystat as select from zmw_paystat_t
association [0..*] to ZMW_I_PAYSTATTXT as _PayTxt on $projection.Paystat = _PayTxt.Paystat
{
    @UI.textArrangement: #TEXT_ONLY
    @UI.lineItem: [{importance: #HIGH}]
    @ObjectModel.text.association: '_PayTxt'
    key paystat as Paystat,
    
    _PayTxt
}
