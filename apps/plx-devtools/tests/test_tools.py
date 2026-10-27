import string
from datetime import datetime

import pytest
from fastapi.testclient import TestClient

import tools
from main import app

client = TestClient(app)


# --- tools.py ------------------------------------------------------------------

def test_password_has_every_selected_set():
    pw = tools.generate_password(length=12)
    assert len(pw) == 12
    assert any(c in string.ascii_uppercase for c in pw)
    assert any(c in string.ascii_lowercase for c in pw)
    assert any(c in string.digits for c in pw)
    assert any(c in tools.SYMBOLS for c in pw)


def test_password_digits_only():
    assert tools.generate_password(10, upper=False, lower=False, symbols=False).isdigit()


def test_password_needs_a_set():
    with pytest.raises(ValueError):
        tools.generate_password(10, False, False, False, False)


def test_token_lengths():
    assert len(tools.generate_token(16, "hex")) == 32


def test_sha256_known_value():
    assert tools.hash_text("abc") == (
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    )


def test_base64_round_trip():
    encoded = tools.base64_encode("hello plixa")
    assert encoded == "aGVsbG8gcGxpeGE="
    assert tools.base64_decode(encoded) == "hello plixa"


def test_base64_rejects_garbage():
    with pytest.raises(ValueError):
        tools.base64_decode("not base64!!")


def test_cidr_azure_reserved():
    info = tools.cidr_info("10.10.1.0/24")
    assert info["total_addresses"] == 256
    assert info["usable_hosts"] == 254
    assert info["azure_usable"] == 251
    assert info["azure_first_usable"] == "10.10.1.4"


def test_cidr_normalises_host_bits_and_splits():
    info = tools.cidr_info("10.10.5.7/16", split_prefix=18)
    assert info["cidr"] == "10.10.0.0/16"
    assert info["subnets"] == ["10.10.0.0/18", "10.10.64.0/18", "10.10.128.0/18", "10.10.192.0/18"]


def test_cidr_split_limit():
    with pytest.raises(ValueError):
        tools.cidr_info("10.0.0.0/8", split_prefix=24)


def test_cron_weekday_business_hours():
    # 2026-10-30 is a Friday.
    result = tools.explain_cron("0 9 * * mon-fri", runs=3, now=datetime(2026, 10, 30, 10, 0))
    assert result["next_runs"] == [
        "2026-11-02 09:00 (Mon)",
        "2026-11-03 09:00 (Tue)",
        "2026-11-04 09:00 (Wed)",
    ]
    assert result["description"].startswith("At 09:00")


def test_cron_step_wording():
    assert tools.explain_cron("*/15 9-17 * * *")["description"] == (
        "Every 15 minutes, hour 9 through 17"
    )


def test_cron_macro_and_sunday_as_7():
    assert tools.explain_cron("@daily")["expression"] == "0 0 * * *"
    sunday = tools.explain_cron("0 0 * * 7", runs=1, now=datetime(2026, 10, 27))
    assert sunday["next_runs"] == ["2026-11-01 00:00 (Sun)"]


@pytest.mark.parametrize("bad", ["* * *", "60 * * * *", "*/0 * * * *", "5-1 * * * *"])
def test_cron_rejects_bad_input(bad):
    with pytest.raises(ValueError):
        tools.explain_cron(bad)


# --- API -----------------------------------------------------------------------

def test_health_and_index():
    assert client.get("/healthz").json() == {"status": "ok"}
    assert "Plixa DevTools" in client.get("/").text


def test_api_errors_are_400_not_500():
    assert client.post("/api/cidr", json={"cidr": "nope"}).status_code == 400


def test_api_validates_limits():
    assert client.post("/api/password", json={"length": 500}).status_code == 422
