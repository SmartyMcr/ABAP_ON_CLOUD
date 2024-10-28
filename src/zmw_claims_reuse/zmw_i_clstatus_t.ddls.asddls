@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Claim Status Text'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #MASTER
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZMW_I_CLSTATUS_T
  as select from zmw_clstatus_t
  association [1..1] to ZMW_I_Status as _Status on $projection.ClaimStatus = _Status.ClaimStatus

{
      @ObjectModel.text.element: ['Text']
  key status   as ClaimStatus,

      @Semantics.language: true
  key language as Language,

      @Semantics.text: true
      text     as Text,

      _Status
}
