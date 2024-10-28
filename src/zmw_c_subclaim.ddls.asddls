@EndUserText.label: 'Subclaim Projection'
//@Metadata.ignorePropagatedAnnotations: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZMW_C_SUBCLAIM
  as projection on ZMW_I_Subclaim

{

  key Claim as Claim,
  key Subclaim as Subclaim,
      Subcltype as Subcltype,
      Status as Status,
      Coverage as Coverage,
      Opendate as Opendate,
      TotalPaid as TotalPaid,
      CurrencyCode as CurrencyCode,
      Complexity as Complexity,
      CreatedBy as CreatedBy,
      CreatedAt as CreatedAt,
      LocalLastChangedBy as LocalLastChangedBy,
      LocalLastChangedAt as LocalLastChangedAt,
      LastChangedAt as LastChangedAt,
      
      /* Associations */
      _Claim : redirected to parent ZMW_C_CLAIM,
      _Pay : redirected to composition child ZMW_C_PAY,
      _Status
}
