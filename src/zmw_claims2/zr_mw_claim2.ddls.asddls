@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_MW_CLAIM2
  as select from zmw_claim as Claim2
  composition [0..*] of ZMW_I_Subclaim2 as _Subclaim2

  association [1..1] to ZMW_I_Status    as _Status  on $projection.Status = _Status.ClaimStatus
  association [1..1] to ZMW_I_POLPROD   as _PolProd on $projection.Polprod = _PolProd.Polprod
  association [1..1] to ZMW_I_CLTYPE    as _ClType  on $projection.Clmtype = _ClType.Clmtype

{
  key claim                 as Claim,
      polprod               as Polprod,
      clmtype               as Clmtype,
      status                as Status,
      policy                as Policy,
      lossdate              as Lossdate,
      opendate              as Opendate,
      claim_desc            as ClaimDesc,
      @Semantics.amount.currencyCode: 'Currencycode'
      bookingfee            as Bookingfee,
      @Semantics.amount.currencyCode: 'Currencycode'
      totalprice            as Totalprice,
      currencycode          as Currencycode,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Subclaim2,
      _Status,
      _PolProd,
      _ClType

}
