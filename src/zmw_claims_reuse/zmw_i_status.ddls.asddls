@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Claim Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MASTER
}
@ObjectModel.resultSet.sizeCategory: #XS  //Prevents pop up box appearing 

define view entity ZMW_I_Status
  as select from zmw_clstatus
  association [0..*] to ZMW_I_CLSTATUS_T as _Text on $projection.ClaimStatus = _Text.ClaimStatus
{
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{importance: #HIGH}]
      @ObjectModel.text.association: '_Text'
  key status as ClaimStatus,

      _Text
}
