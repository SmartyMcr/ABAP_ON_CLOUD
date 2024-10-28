@Metadata.allowExtensions: true
@EndUserText.label: 'Claim Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
 
define root view entity ZMW_C_CLAIM
  provider contract transactional_query
  as projection on ZMW_R_CLAIM
  
{
  @Search.defaultSearchElement: true
  key Claim,

 
  @Consumption.valueHelpDefinition: [{ 
                entity.name: 'ZMW_I_POLPROD',
                entity.element: 'Polprod'
     }]
  @ObjectModel.text.element: [ 'Polprodtext' ]
  Polprod,
  @Semantics.text: true
  _PolProd._Text.Text as Polprodtext : localized,

  @Consumption.valueHelpDefinition: [{ 
                entity.name: 'ZMW_I_CLTYPE',
                entity.element: 'Clmtype'
     }]
  @ObjectModel.text.element: [ 'ClmTypText' ]
  Clmtype,
  @Semantics.text: true
  _ClType._ClTypeTXT.Text as ClmTypText : localized,

  @Consumption.valueHelpDefinition: [{ 
                entity.name: 'ZMW_I_STATUS',
                entity.element: 'ClaimStatus'
     }]
  @ObjectModel.text.element: [ 'StatusText' ]
  Status,
  @Semantics.text: true
  StatusText,
  Criticality,
  Policy,
  Lossdate,
  Opendate,
  ClaimDesc,
  TotalPrice,
  CurrencyCode,
  BookingFee,
  CreatedBy,
  CreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  
  _Subclaim : redirected to composition child ZMW_C_SUBCLAIM,  // Used to allow table display on screen
  _PolProd,
  _Status,
  _ClType,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_VIRTUAL_CALC'
    @EndUserText.label: 'CO2 Tax'
    virtual deductable : abap.int4,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_VIRTUAL_CALC'
    @EndUserText.label: 'Week Day'
    virtual dayOfTheClaim : abap.char( 9 )  
}
