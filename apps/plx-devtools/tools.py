"""Pure tool logic, kept free of any web framework so it can be unit-tested
directly and reused from the API layer in main.py."""

import base64
import binascii
import hashlib
import ipaddress
import secrets
import string
from datetime import datetime, timedelta, timezone

# --- Password / token generator ----------------------------------------------

SYMBOLS = "!@#$%^&*()-_=+[]{}:,.?"


def generate_password(length=20, upper=True, lower=True, digits=True, symbols=True):
    pools = [
        p
        for p, on in (
            (string.ascii_uppercase, upper),
            (string.ascii_lowercase, lower),
            (string.digits, digits),
            (SYMBOLS, symbols),
        )
        if on
    ]
    if not pools:
        raise ValueError("Select at least one character set.")
    if length < len(pools):
        raise ValueError("Length is shorter than the number of selected sets.")

    # One guaranteed character from each selected set, the rest from all of
    # them, then shuffle so the guaranteed ones aren't always at the front.
    # `secrets` uses the OS CSPRNG; `random` must never be used for secrets.
    alphabet = "".join(pools)
    chars = [secrets.choice(p) for p in pools]
    chars += [secrets.choice(alphabet) for _ in range(length - len(pools))]
    secrets.SystemRandom().shuffle(chars)
    return "".join(chars)


def generate_token(nbytes=32, fmt="hex"):
    if fmt == "hex":
        return secrets.token_hex(nbytes)
    if fmt == "urlsafe":
        return secrets.token_urlsafe(nbytes)
    raise ValueError("Format must be 'hex' or 'urlsafe'.")


# --- Hash / Base64 -----------------------------------------------------------

# md5 and sha1 are broken for security use; they're offered for checksums only.
HASH_ALGORITHMS = ("md5", "sha1", "sha256", "sha512")


def hash_text(text, algorithm="sha256"):
    if algorithm not in HASH_ALGORITHMS:
        raise ValueError(f"Algorithm must be one of {', '.join(HASH_ALGORITHMS)}.")
    h = hashlib.new(algorithm, usedforsecurity=algorithm not in ("md5", "sha1"))
    h.update(text.encode())
    return h.hexdigest()


def base64_encode(text, urlsafe=False):
    raw = text.encode()
    out = base64.urlsafe_b64encode(raw) if urlsafe else base64.b64encode(raw)
    return out.decode()


def base64_decode(text, urlsafe=False):
    try:
        raw = (
            base64.urlsafe_b64decode(text)
            if urlsafe
            else base64.b64decode(text, validate=True)
        )
        return raw.decode()
    except (binascii.Error, ValueError):
        raise ValueError("Input is not valid Base64 (or does not decode to UTF-8 text).")


# --- CIDR / subnet calculator --------------------------------------------------

# Azure reserves 5 addresses in every subnet: network, .1 gateway, .2 and .3
# for Azure DNS, and broadcast. The smallest subnet Azure allows is /29.
AZURE_RESERVED = 5
MAX_SPLIT = 256


def cidr_info(cidr, split_prefix=None):
    try:
        net = ipaddress.ip_network(cidr.strip(), strict=False)
    except ValueError as e:
        raise ValueError(f"Invalid CIDR: {e}")
    if net.version != 4:
        raise ValueError("Only IPv4 is supported.")

    total = net.num_addresses
    if net.prefixlen <= 30:
        first, last, usable = net[1], net[-2], total - 2
    else:  # /31 and /32 have no network/broadcast (RFC 3021)
        first, last, usable = net[0], net[-1], total

    info = {
        "cidr": str(net),
        "network": str(net.network_address),
        "netmask": str(net.netmask),
        "wildcard": str(net.hostmask),
        "broadcast": str(net.broadcast_address),
        "prefix": net.prefixlen,
        "total_addresses": total,
        "usable_hosts": usable,
        "first_usable": str(first),
        "last_usable": str(last),
        "is_private": net.is_private,
        "azure_usable": total - AZURE_RESERVED if net.prefixlen <= 29 else None,
        "azure_first_usable": str(net[4]) if net.prefixlen <= 29 else None,
    }

    if split_prefix is not None:
        if not net.prefixlen < split_prefix <= 32:
            raise ValueError(f"Split prefix must be between /{net.prefixlen + 1} and /32.")
        count = 2 ** (split_prefix - net.prefixlen)
        if count > MAX_SPLIT:
            raise ValueError(f"That split makes {count} subnets; the limit is {MAX_SPLIT}.")
        info["subnets"] = [str(s) for s in net.subnets(new_prefix=split_prefix)]

    return info


# --- Cron expression explainer -------------------------------------------------

MONTH_NAMES = ["jan", "feb", "mar", "apr", "may", "jun",
               "jul", "aug", "sep", "oct", "nov", "dec"]
DAY_NAMES = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]

# (name, min, max, name aliases)
CRON_FIELDS = (
    ("minute", 0, 59, None),
    ("hour", 0, 23, None),
    ("day of month", 1, 31, None),
    ("month", 1, 12, MONTH_NAMES),
    ("day of week", 0, 7, DAY_NAMES),  # 0 and 7 are both Sunday
)

CRON_MACROS = {
    "@yearly": "0 0 1 1 *",
    "@annually": "0 0 1 1 *",
    "@monthly": "0 0 1 * *",
    "@weekly": "0 0 * * 0",
    "@daily": "0 0 * * *",
    "@midnight": "0 0 * * *",
    "@hourly": "0 * * * *",
}


def _cron_value(token, lo, hi, names, field):
    token = token.lower()
    if names and token in names:
        return names.index(token) + lo
    if not token.isdigit():
        raise ValueError(f"Bad value '{token}' in {field}.")
    value = int(token)
    if not lo <= value <= hi:
        raise ValueError(f"{field} value {value} is out of range {lo}-{hi}.")
    return value


def _parse_cron_field(expr, lo, hi, names, field):
    values = set()
    for part in expr.split(","):
        step = 1
        if "/" in part:
            part, step_s = part.split("/", 1)
            if not step_s.isdigit() or int(step_s) == 0:
                raise ValueError(f"Bad step '{step_s}' in {field}.")
            step = int(step_s)
        if part == "*":
            start, end = lo, hi
        elif "-" in part:
            a, b = part.split("-", 1)
            start = _cron_value(a, lo, hi, names, field)
            end = _cron_value(b, lo, hi, names, field)
            if start > end:
                raise ValueError(f"Range {part} in {field} runs backwards.")
        else:
            start = _cron_value(part, lo, hi, names, field)
            end = hi if step > 1 else start  # "5/15" means from 5 to max
        values.update(range(start, end + 1, step))
    if field == "day of week" and 7 in values:
        values = (values - {7}) | {0}
    return values


def _describe_field(expr, field, names):
    if expr == "*":
        return None
    if expr.startswith("*/"):
        return f"every {expr[2:]} {field}s"

    def label(v):
        if not names:
            return v
        if not v.isdigit():
            return v.capitalize()
        index = int(v) - 1 if field == "month" else int(v) % 7
        return names[index].capitalize()

    parts = []
    for part in expr.split(","):
        base, _, step = part.partition("/")
        if "-" in base:
            a, b = base.split("-", 1)
            text = f"{label(a)} through {label(b)}"
        else:
            text = label(base)
        parts.append(f"{text} (every {step})" if step else text)
    return f"{field} {', '.join(parts)}"


def explain_cron(expr, runs=5, now=None):
    expr = expr.strip()
    expr = CRON_MACROS.get(expr.lower(), expr)
    fields = expr.split()
    if len(fields) != 5:
        raise ValueError(
            "A cron expression needs exactly 5 fields: minute hour day-of-month month day-of-week."
        )

    sets = [_parse_cron_field(f, lo, hi, names, name)
            for f, (name, lo, hi, names) in zip(fields, CRON_FIELDS)]
    minutes, hours, doms, months, dows = sets

    # Wording
    m, h = fields[0], fields[1]
    if m.isdigit() and h.isdigit():
        when = f"At {int(h):02d}:{int(m):02d}"
    else:
        bits = [_describe_field(m, "minute", None) or "every minute",
                _describe_field(h, "hour", None)]
        when = ", ".join(b for b in bits if b)
        when = when[0].upper() + when[1:]
    extras = [_describe_field(f, name, names)
              for f, (name, _, _, names) in zip(fields[2:], CRON_FIELDS[2:])]
    description = ", ".join([when] + [e for e in extras if e])
    if fields[2] != "*" and fields[4] != "*":
        description += " (runs when EITHER the day-of-month OR the day-of-week matches)"

    # Next run times. Standard cron rule: if both day fields are restricted,
    # a day matches when either one matches; otherwise both must match.
    dom_any, dow_any = fields[2] == "*", fields[4] == "*"
    # Cron schedules on Azure and GitHub Actions run in UTC, so compute in UTC.
    now = now or datetime.now(timezone.utc).replace(tzinfo=None)
    now = now.replace(second=0, microsecond=0) + timedelta(minutes=1)
    upcoming = []
    day = now.replace(hour=0, minute=0)
    for _ in range(366 * 5):  # up to 5 years ahead covers Feb 29 schedules
        cron_dow = (day.weekday() + 1) % 7  # Python Monday=0 -> cron Sunday=0
        dom_ok, dow_ok = day.day in doms, cron_dow in dows
        day_ok = (dom_ok and dow_ok) if (dom_any or dow_any) else (dom_ok or dow_ok)
        if day.month in months and day_ok:
            for hr in sorted(hours):
                for mi in sorted(minutes):
                    t = day.replace(hour=hr, minute=mi)
                    if t >= now:
                        upcoming.append(t.strftime("%Y-%m-%d %H:%M (%a)"))
                        if len(upcoming) == runs:
                            return {"expression": expr, "description": description,
                                    "next_runs": upcoming}
        day += timedelta(days=1)

    return {"expression": expr, "description": description, "next_runs": upcoming}
