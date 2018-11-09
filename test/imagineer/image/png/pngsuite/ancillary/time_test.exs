defmodule Imagineer.Image.PNG.PngSuite.Ancillary.TimeTest do
  use ExUnit.Case, async: true

  @test_path "test/support/images/pngsuite/ancillary/"

  test "unix epoch" do
    {:ok, image} = Imagineer.load(@test_path <> "cm7n0g04.png")

    assert image.last_modified == %DateTime{
             year: 1970,
             month: 1,
             day: 1,
             hour: 0,
             minute: 0,
             second: 0,
             std_offset: 0,
             time_zone: "Etc/UTC",
             utc_offset: 0,
             zone_abbr: "UTC"
           }
  end

  test "last second of the 20th century" do
    {:ok, image} = Imagineer.load(@test_path <> "cm9n0g04.png")

    assert image.last_modified == %DateTime{
             year: 1999,
             month: 12,
             day: 31,
             hour: 23,
             minute: 59,
             second: 59,
             std_offset: 0,
             time_zone: "Etc/UTC",
             utc_offset: 0,
             zone_abbr: "UTC"
           }
  end

  test "the first afternoon of the 21st century" do
    {:ok, image} = Imagineer.load(@test_path <> "cm0n0g04.png")

    assert image.last_modified == %DateTime{
             year: 2000,
             month: 1,
             day: 1,
             hour: 12,
             minute: 34,
             second: 56,
             std_offset: 0,
             time_zone: "Etc/UTC",
             utc_offset: 0,
             zone_abbr: "UTC"
           }
  end
end
