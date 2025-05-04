import math
import numpy as np
from typing import Tuple

def is_prime(n: int) -> bool:
    """Check if a number is prime."""
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

def bit_count(n: int) -> int:
    """Count the number of 1 bits in a number."""
    return bin(n).count('1')

def calculate_w_constants() -> Tuple[int, int]:
    """Calculate W constants based on golden ratio for 16-bit."""
    phi = (1 + math.sqrt(5)) / 2
    w1 = int((phi * (2**16)) % 2**16)
    w2 = int((phi * phi * (2**16)) % 2**16)
    return w1, w2

def find_m4_constants() -> Tuple[int, int]:
    """Find suitable M4 constants that are prime and have good bit distribution."""
    best_m4_1 = 0
    best_m4_2 = 0
    best_score = 0
    
    # Search range for 16-bit primes
    for n in range(0x8000, 0x10000):  # Focus on upper half for better mixing
        if not is_prime(n):
            continue
            
        bits = bit_count(n)
        # Prefer numbers with roughly half bits set (good mixing)
        bit_balance = abs(bits - 8)  # 8 is half of 16 bits
        # Score based on bit balance and prime property
        score = (16 - bit_balance) 
        
        if score > best_score:
            if best_m4_1 == 0:
                best_m4_1 = n
                best_score = score
            else:
                # Make sure the two constants are different enough
                if abs(n - best_m4_1) > 0x1000:  # Minimum difference threshold
                    best_m4_2 = n
                    break
                    
    return best_m4_1, best_m4_2

def test_distribution(w1: int, w2: int, m4_1: int, m4_2: int, samples: int = 10000):
    """Test the statistical properties of the constants."""
    def mulhi16(a: int, b: int) -> int:
        return (a * b) >> 16
    
    def philox_round(ctr: list, key: list) -> list:
        hi1 = mulhi16(m4_1, ctr[0])
        lo1 = (m4_1 * ctr[0]) & 0xFFFF
        hi2 = mulhi16(m4_2, ctr[2])
        lo2 = (m4_2 * ctr[2]) & 0xFFFF
        
        return [
            hi2 ^ ctr[1] ^ key[0],
            lo2,
            hi1 ^ ctr[3] ^ key[1],
            lo1
        ]
    
    results = []
    key = [w1, w2]
    
    for i in range(samples):
        ctr = [i & 0xFFFF, 0, 0, 0]
        for _ in range(10):  # 10 rounds
            ctr = philox_round(ctr, key)
            key = [(k + w) & 0xFFFF for k, w in zip(key, [w1, w2])]
        
        # Convert to float between 0 and 1
        for x in ctr:
            results.append(x / 65536.0)
    
    results = np.array(results)
    mean = np.mean(results)
    var = np.var(results)
    
    print(f"\nStatistical Test Results:")
    print(f"Mean (should be close to 0.5): {mean:.6f}")
    print(f"Variance (should be close to 1/12 ≈ 0.0833): {var:.6f}")
    
    # Chi-square test for uniformity
    hist, _ = np.histogram(results, bins=20)
    expected = len(results) / 20
    chi2 = np.sum((hist - expected)**2 / expected)
    print(f"Chi-square statistic: {chi2:.2f}")
    print(f"(Should be close to degrees of freedom = 19)")

def main():
    w1, w2 = calculate_w_constants()
    m4_1, m4_2 = find_m4_constants()
    
    print(f"Calculated constants:")
    print(f"W1 = 0x{w1:04X}")
    print(f"W2 = 0x{w2:04X}")
    print(f"M4_1 = 0x{m4_1:04X}")
    print(f"M4_2 = 0x{m4_2:04X}")
    
    test_distribution(w1, w2, m4_1, m4_2)

if __name__ == "__main__":
    main()