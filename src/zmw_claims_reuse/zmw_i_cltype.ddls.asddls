@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Claim Type CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS  //Prevents pop up box appearing just a drop down
define view entity ZMW_I_CLTYPE as select from zmw_cltype_t
  association [0..*] to ZMW_I_CLTYPETXT as _ClTypeTXT on $projection.Clmtype = _ClTypeTXT.Cltype
  
{
    key clmtype as Clmtype,
    
    _ClTypeTXT
}
