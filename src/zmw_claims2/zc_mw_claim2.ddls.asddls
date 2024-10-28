@Metadata.allowExtensions: true
@EndUserText.label: 'Claim2 Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@ObjectModel.semanticKey: [ 'Claim' ]
@Search.searchable: true
define root view entity ZC_MW_CLAIM2
  provider contract transactional_query
  as projection on ZR_MW_CLAIM2
{
          @Search.fuzzinessThreshold: 0.90
          @Search.defaultSearchElement: true
  key     Claim,

          //   ---------POLPROD f4 example----------
          @Consumption.valueHelpDefinition: [{
                        entity.name: 'ZMW_I_POLPROD',
                        entity.element: 'Polprod'
             }]
          @ObjectModel.text.element: [ 'Polprodtext' ]
          Polprod,
          @Semantics.text: true
          _PolProd._Text.Text     as Polprodtext : localized,

          //   -------------------------------------
          @Consumption.valueHelpDefinition: [{
                        entity.name: 'ZMW_I_CLTYPE',
                        entity.element: 'Clmtype'
             }]
          @ObjectModel.text.element: [ 'ClmTypText' ]
          Clmtype,
          @Semantics.text: true
          _ClType._ClTypeTXT.Text as ClmTypText  : localized,

          //   -------------------------------------------
          @Consumption.valueHelpDefinition: [{
                        entity.name: 'ZMW_I_STATUS',
                        entity.element: 'ClaimStatus'
             }]
          @ObjectModel.text.element: [ 'StatusText' ]

          Status,
          @Semantics.text: true
          _Status._Text.Text      as StatusText  : localized,
          //   -------------------------------------------

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MW_CALC_CLAIM_ELEM'
          @EndUserText.label: 'Overall Status Indicator'
  virtual OverallStatusIndicator : abap.int2,

          Policy,
          Lossdate,
          Opendate,
          ClaimDesc,
          @Semantics.amount.currencyCode: 'Currencycode'
          Bookingfee,
          @Semantics.amount.currencyCode: 'Currencycode'
          Totalprice,
          @Consumption.valueHelpDefinition: [ {
            entity: {
              name: 'I_CurrencyStdVH',
              element: 'Currency'
            },
            useForValidation: true
          } ]
          @Semantics.currencyCode: true
          Currencycode,
          CreatedBy,
          CreatedAt,
          LocalLastChangedBy,
          LocalLastChangedAt,
          LastChangedAt,

          _Subclaim2 : redirected to composition child ZMW_C_SUBCLAIM2, // Used to allow table display on screen
          _PolProd,
          _Status,
          _ClType
}
