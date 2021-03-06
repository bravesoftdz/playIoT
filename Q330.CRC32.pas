unit Q330.CRC32;

interface

uses
  Windows, Classes, SysUtils, System.StrUtils, JdcGlobal, IdGlobal;

function CalcCRC32(AData: TIdBytes): DWord;

implementation

const

  /// ////////////////////////////////////////////////////////////////////////
  /// Q330 CRC32 Table
  /// Polynomial : 0x56070368(1443300200L)
  /// Width : 4
  /// Reverse : True
  ///
  ///

  Table: Array [0 .. 255] of DWord = ($00000000, $165B66A9, $01370D87,
    $176C6B2E, $026E1B0E, $14357DA7, $03591689, $15027020, $04DC361C, $128750B5,
    $05EB3B9B, $13B05D32, $06B22D12, $10E94BBB, $07852095, $11DE463C, $09B86C38,
    $1FE30A91, $088F61BF, $1ED40716, $0BD67736, $1D8D119F, $0AE17AB1, $1CBA1C18,
    $0D645A24, $1B3F3C8D, $0C5357A3, $1A08310A, $0F0A412A, $19512783, $0E3D4CAD,
    $18662A04, $1370D870, $052BBED9, $1247D5F7, $041CB35E, $111EC37E, $0745A5D7,
    $1029CEF9, $0672A850, $17ACEE6C, $01F788C5, $169BE3EB, $00C08542, $15C2F562,
    $039993CB, $14F5F8E5, $02AE9E4C, $1AC8B448, $0C93D2E1, $1BFFB9CF, $0DA4DF66,
    $18A6AF46, $0EFDC9EF, $1991A2C1, $0FCAC468, $1E148254, $084FE4FD, $1F238FD3,
    $0978E97A, $1C7A995A, $0A21FFF3, $1D4D94DD, $0B16F274, $0B607035, $1D3B169C,
    $0A577DB2, $1C0C1B1B, $090E6B3B, $1F550D92, $083966BC, $1E620015, $0FBC4629,
    $19E72080, $0E8B4BAE, $18D02D07, $0DD25D27, $1B893B8E, $0CE550A0, $1ABE3609,
    $02D81C0D, $14837AA4, $03EF118A, $15B47723, $00B60703, $16ED61AA, $01810A84,
    $17DA6C2D, $06042A11, $105F4CB8, $07332796, $1168413F, $046A311F, $123157B6,
    $055D3C98, $13065A31, $1810A845, $0E4BCEEC, $1927A5C2, $0F7CC36B, $1A7EB34B,
    $0C25D5E2, $1B49BECC, $0D12D865, $1CCC9E59, $0A97F8F0, $1DFB93DE, $0BA0F577,
    $1EA28557, $08F9E3FE, $1F9588D0, $09CEEE79, $11A8C47D, $07F3A2D4, $109FC9FA,
    $06C4AF53, $13C6DF73, $059DB9DA, $12F1D2F4, $04AAB45D, $1574F261, $032F94C8,
    $1443FFE6, $0218994F, $171AE96F, $01418FC6, $162DE4E8, $00768241, $16C0E06A,
    $009B86C3, $17F7EDED, $01AC8B44, $14AEFB64, $02F59DCD, $1599F6E3, $03C2904A,
    $121CD676, $0447B0DF, $132BDBF1, $0570BD58, $1072CD78, $0629ABD1, $1145C0FF,
    $071EA656, $1F788C52, $0923EAFB, $1E4F81D5, $0814E77C, $1D16975C, $0B4DF1F5,
    $1C219ADB, $0A7AFC72, $1BA4BA4E, $0DFFDCE7, $1A93B7C9, $0CC8D160, $19CAA140,
    $0F91C7E9, $18FDACC7, $0EA6CA6E, $05B0381A, $13EB5EB3, $0487359D, $12DC5334,
    $07DE2314, $118545BD, $06E92E93, $10B2483A, $016C0E06, $173768AF, $005B0381,
    $16006528, $03021508, $155973A1, $0235188F, $146E7E26, $0C085422, $1A53328B,
    $0D3F59A5, $1B643F0C, $0E664F2C, $183D2985, $0F5142AB, $190A2402, $08D4623E,
    $1E8F0497, $09E36FB9, $1FB80910, $0ABA7930, $1CE11F99, $0B8D74B7, $1DD6121E,
    $1DA0905F, $0BFBF6F6, $1C979DD8, $0ACCFB71, $1FCE8B51, $0995EDF8, $1EF986D6,
    $08A2E07F, $197CA643, $0F27C0EA, $184BABC4, $0E10CD6D, $1B12BD4D, $0D49DBE4,
    $1A25B0CA, $0C7ED663, $1418FC67, $02439ACE, $152FF1E0, $03749749, $1676E769,
    $002D81C0, $1741EAEE, $011A8C47, $10C4CA7B, $069FACD2, $11F3C7FC, $07A8A155,
    $12AAD175, $04F1B7DC, $139DDCF2, $05C6BA5B, $0ED0482F, $188B2E86, $0FE745A8,
    $19BC2301, $0CBE5321, $1AE53588, $0D895EA6, $1BD2380F, $0A0C7E33, $1C57189A,
    $0B3B73B4, $1D60151D, $0862653D, $1E390394, $095568BA, $1F0E0E13, $07682417,
    $113342BE, $065F2990, $10044F39, $05063F19, $135D59B0, $0431329E, $126A5437,
    $03B4120B, $15EF74A2, $02831F8C, $14D87925, $01DA0905, $17816FAC, $00ED0482,
    $16B6622B);

function ReverseDWord(AValue: DWord): DWord;
var
  I: integer;
begin
  result := 0;
  for I := 1 to SizeOf(DWord) * 8 do
  begin
    result := result shl 1;
    if (AValue and 1) = 1 then
    begin
      result := result or 1;
    end;
    AValue := AValue shr 1;
  end;
end;

function ReverseByte(AValue: Byte): Byte;
var
  I: integer;
begin
  result := 0;
  for I := 1 to SizeOf(Byte) * 8 do
  begin
    result := result shl 1;
    if (AValue and 1) = 1 then
    begin
      result := result or 1;
    end;
    AValue := AValue shr 1;
  end;
end;

function UpdateCRC32(AByte: Byte; AValue: DWord): DWord;
var
  B: Byte;
begin
  B := ReverseByte(AByte);
  result := (AValue shr 8) xor Table[B xor (AValue and $FF)];
end;

function CalcCRC32(AData: TIdBytes): DWord;
var
  I: integer;
begin
  result := $00;
{$I-}
  for I := 0 to Length(AData) - 1 do
  begin
    result := UpdateCRC32(AData[I], result);
  end;
  result := ReverseDWord(result);
{$I+}
  if result = 0 then
    result := 1;
end;

end.
