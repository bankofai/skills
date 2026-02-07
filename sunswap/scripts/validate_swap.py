#!/usr/bin/env python3
"""
SunSwap Swap Validation Helper

This script helps validate and prepare swap parameters for SunSwap DEX.
"""

import argparse
import time
from decimal import Decimal


def calculate_min_amount(amount: float, slippage: float, decimals: int = 6) -> int:
    """
    Calculate minimum output amount with slippage protection.
    
    Args:
        amount: Expected output amount (human-readable)
        slippage: Slippage tolerance (e.g., 0.01 for 1%)
        decimals: Token decimals (default: 6)
    
    Returns:
        Minimum amount in smallest unit (int)
    """
    amount_decimal = Decimal(str(amount))
    slippage_decimal = Decimal(str(slippage))
    
    min_amount = amount_decimal * (Decimal('1') - slippage_decimal)
    min_amount_raw = int(min_amount * (Decimal('10') ** decimals))
    
    return min_amount_raw


def generate_deadline(minutes: int = 5) -> int:
    """
    Generate deadline timestamp.
    
    Args:
        minutes: Minutes from now (default: 5)
    
    Returns:
        Unix timestamp
    """
    return int(time.time()) + (minutes * 60)


def format_amount(amount: float, decimals: int = 6) -> str:
    """
    Format human-readable amount to smallest unit.
    
    Args:
        amount: Amount (e.g., 100.5)
        decimals: Token decimals
    
    Returns:
        Amount in smallest unit as string
    """
    amount_decimal = Decimal(str(amount))
    amount_raw = int(amount_decimal * (Decimal('10') ** decimals))
    return str(amount_raw)


def validate_swap_params(
    amount_in: float,
    amount_out: float,
    slippage: float,
    decimals_in: int = 6,
    decimals_out: int = 6,
) -> dict:
    """
    Validate and prepare all swap parameters.
    
    Args:
        amount_in: Input amount
        amount_out: Expected output amount
        slippage: Slippage tolerance
        decimals_in: Input token decimals
        decimals_out: Output token decimals
    
    Returns:
        Dictionary with formatted parameters
    """
    amount_in_raw = format_amount(amount_in, decimals_in)
    amount_out_min = calculate_min_amount(amount_out, slippage, decimals_out)
    deadline = generate_deadline()
    
    return {
        "amount_in": amount_in_raw,
        "amount_out_min": str(amount_out_min),
        "deadline": deadline,
        "slippage_percent": slippage * 100,
        "expected_output": amount_out,
        "minimum_output": amount_out * (1 - slippage),
    }


def main():
    parser = argparse.ArgumentParser(
        description="Validate SunSwap swap parameters"
    )
    parser.add_argument(
        "--amount",
        type=float,
        required=True,
        help="Expected output amount (e.g., 385 for 385 TRX)"
    )
    parser.add_argument(
        "--slippage",
        type=float,
        default=0.01,
        help="Slippage tolerance (default: 0.01 for 1%%)"
    )
    parser.add_argument(
        "--decimals",
        type=int,
        default=6,
        help="Token decimals (default: 6)"
    )
    parser.add_argument(
        "--deadline-minutes",
        type=int,
        default=5,
        help="Deadline in minutes from now (default: 5)"
    )
    
    args = parser.parse_args()
    
    # Calculate minimum amount
    min_amount = calculate_min_amount(args.amount, args.slippage, args.decimals)
    
    # Generate deadline
    deadline = generate_deadline(args.deadline_minutes)
    
    # Print results
    print(f"Expected output: {args.amount}")
    print(f"Slippage: {args.slippage * 100}%")
    print(f"Minimum output: {args.amount * (1 - args.slippage)}")
    print(f"---")
    print(f"Minimum amount (raw): {min_amount}")
    print(f"Deadline: {deadline}")
    print(f"Deadline (readable): {time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(deadline))}")


if __name__ == "__main__":
    main()
