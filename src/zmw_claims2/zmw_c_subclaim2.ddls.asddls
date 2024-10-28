@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Subclaim2 Projection'
@ObjectModel.semanticKey: [ 'Claim' ]
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZMW_C_SUBCLAIM2
//  provider contract transactional_query
  as projection on ZMW_I_Subclaim2
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Claim,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key Subclaim,
      Subcltype,

      //   -------------------------------------------
      @Consumption.valueHelpDefinition: [{
                    entity.name: 'ZMW_I_STATUS',
                    entity.element: 'ClaimStatus'
         }]
      @ObjectModel.text.element: [ 'StatusText' ]
      Status,
      @Semantics.text: true
      _Status._Text.Text as statusText  : localized,
      
      Coverage,
      Opendate,
      Complexity,
      TotalPaid,
      CurrencyCode,
      
       @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_CALC_SUBCLAIM_ELEM'
       @EndUserText.label: 'Subclaim Status Indicator'
       virtual SubclaimStatusIndicator : abap.int1,
                                
       @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_CALC_SUBCLAIM_ELEM'
       @EndUserText.label: 'Days Open'
       virtual DaysOpen    : abap.int1, //InitialDaysToFlight
          
       @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_CALC_SUBCLAIM_ELEM'
       @EndUserText.label: 'Remaining Days'
       virtual RemainingDays  : abap.int1, //RemainingDaysToFlight
          
        @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_CALC_SUBCLAIM_ELEM'
        @EndUserText.label: 'Days to Flight Indicator'
        virtual DaysToEnd  : abap.int1,      //DaysToFlightIndicator
      
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Claim2 : redirected to parent ZC_MW_CLAIM2,
//      _Pay2,
      _Status
}
