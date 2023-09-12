import random
import string


def random_string(
    length: int = 32, lower: bool = False, only_numbers: bool = False
) -> str:
    if only_numbers:
        chars = string.digits
    else:
        chars = string.digits + string.ascii_letters
    res = "".join(random.choice(chars) for i in range(length))
    if lower:
        res = res.lower()
    return res
