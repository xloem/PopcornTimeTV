

import UIKit


extension UIScreen {
    
    var aspectRatio: String {
        let numbers = [bounds.width, bounds.height]
        
        // Normalize the input vector to that the maximum is 1.0,
        // and compute rational approximations of all components:
        let maximum = numbers.max()!
        let rats = numbers.map({($0/maximum).rationalApproximation})
        
        // Multiply all rational numbers by the LCM of the denominators:
        let commonDenominator = lcm(rats.map({$0.denominator}))
        let numerators = rats.map({$0.numerator * commonDenominator / $0.denominator})
        
        // Divide the numerators by the GCD of all numerators:
        let commonNumerator = gcd(numerators)
        return numerators.map({ String($0 / commonNumerator) }).joined(separator: ":")
    }
}


typealias Rational = (numerator: Int, denominator: Int)

extension CGFloat {
    var rationalApproximation: Rational {
        var x = self
        let eps: CGFloat = 1e-9
        var a = floor(x)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * CGFloat(k) * CGFloat(k) {
            x = 1.0/(x - a)
            a = floor(x)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
}

/*
 Euclid's algorithm for finding the greatest common divisor
 */
func gcd(_ m: Int, _ n: Int) -> Int {
    var a = 0
    var b = max(m, n)
    var r = min(m, n)
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

// GCD of a vector of numbers:
func gcd(_ vector: [Int]) -> Int {
    return vector.reduce(0, { gcd($0, $1) })
}

// LCM of a vector of numbers:
func lcm(_ vector: [Int]) -> Int {
    return vector.reduce(1, { lcm($0, $1) })
}

/*
 Returns the least common multiple of two numbers.
 */
func lcm(_ m: Int, _ n: Int) -> Int {
    return m*n / gcd(m, n)
}
