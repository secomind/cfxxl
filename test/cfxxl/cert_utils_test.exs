defmodule CFXXL.CertUtilsTest do
  use ExUnit.Case

  alias CFXXL.CertUtils

  @test_crt """
  -----BEGIN CERTIFICATE-----
  MIIDkzCCAnugAwIBAgIJAPvrwmDUKC0EMA0GCSqGSIb3DQEBCwUAMGAxCzAJBgNV
  BAYTAklUMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
  aWRnaXRzIFB0eSBMdGQxGTAXBgNVBAMMEHRlc3QtY29tbW9uLW5hbWUwHhcNMTcx
  MDExMTU1NDA4WhcNMTgxMDExMTU1NDA4WjBgMQswCQYDVQQGEwJJVDETMBEGA1UE
  CAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRk
  MRkwFwYDVQQDDBB0ZXN0LWNvbW1vbi1uYW1lMIIBIjANBgkqhkiG9w0BAQEFAAOC
  AQ8AMIIBCgKCAQEA3GDSP6lBQFNqEzz08yG6xanZFJ54Ikmxxp8g8lXnBkd1XkFa
  oLV53tjQiEgJWZHM7J1SUODx0aDI0eY/LWjI2RZStUl2Qbta4SBfmg6ytgIOD2AB
  65Qhv7qSWQWzmHn2ewz8yknyC4bMMmFxJu7NPbcFAYWkOaVtu5YyIZjKqqXX2Yty
  U7YpqMzkENFmsRG942jFFMGePso5jCp6KUPth/5AlJjjgtLuKW5uu8B2tAO52JBW
  1WC6K9GXyJzCeWTOJzIKYe6iJvuapkbq2L+uR44xSdSkhlIGUe6x95iP3/GJNtQu
  Xn0o+xqk6AUgtS3TLJrtmMhqLsGDFNkNGcafuQIDAQABo1AwTjAdBgNVHQ4EFgQU
  wfK/4fIgZldpWOz0hRSpHNtLzfkwHwYDVR0jBBgwFoAUwfK/4fIgZldpWOz0hRSp
  HNtLzfkwDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAJRBG782QTDHp
  eE5Df5I4srR92mBzhJi17VdmTFI5yjcgld1DUh90HWgVS5J4o4I+N3iB+t7GTb1w
  RPw3x6wFtubToR845DWZJr9r/b4+yOdVGlc1DUebXpDFlk9OUmnLkaC4gDFKMGER
  Q98W205ZmLRH7566ft7P6kK04Pa3w1tjc2nZSE7E2K1CxrJRqurt5XdGFP4Fhc8g
  tyLv2oQvgjxsgmD0q94Xc43MtN2JVbBGGK3olXeRVPK2A8pgomxnaSzgnsribmBI
  FUAoPs9udC2ex6WQOUUZhAKQ7PpK1UbASwhnXdgbC0pnOiZUwzwYb9UG4nlgHmY+
  Z/HHzzaRYA==
  -----END CERTIFICATE-----
  """

  @test_cn "test-common-name"
  @test_aki "c1f2bfe1f22066576958ecf48514a91cdb4bcdf9"
  @test_serial "18152816444178967812"
  @test_not_after DateTime.from_naive!(
                    %NaiveDateTime{
                      year: 2018,
                      month: 10,
                      day: 11,
                      hour: 15,
                      minute: 54,
                      second: 08
                    },
                    "Etc/UTC"
                  )
  @test_not_before DateTime.from_naive!(
                     %NaiveDateTime{
                       year: 2017,
                       month: 10,
                       day: 11,
                       hour: 15,
                       minute: 54,
                       second: 08
                     },
                     "Etc/UTC"
                   )

  test "common name extraction" do
    assert CertUtils.common_name!(@test_crt) == @test_cn
  end

  test "AKI extraction" do
    assert CertUtils.authority_key_identifier!(@test_crt) == @test_aki
  end

  test "serial number extraction" do
    assert CertUtils.serial_number!(@test_crt) == @test_serial
  end

  test "not_after extraction" do
    assert CertUtils.not_after!(@test_crt) == @test_not_after
  end

  test "not_before extraction" do
    assert CertUtils.not_before!(@test_crt) == @test_not_before
  end
end
