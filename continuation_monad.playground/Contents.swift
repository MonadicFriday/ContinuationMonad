// Playground - noun: a place where people can play
public func id<A>(x : A) -> A {
    return x
}

public func error<A>(_ x : String) -> A {
    assert(false, x)
}

/// The Continuation Monad
public struct Cont<R, A> {
    let run : (@escaping (A) -> R) -> R
    
    init(_ run : @escaping (@escaping (A) -> R) -> R) {
        self.run = run
    }
    
    public static func pure(_ a : A) -> Cont<R, A> {
        return Cont({ f in f(a) })
    }
}

public func bind<R, A, B>(c : Cont<R, A>, f : @escaping (A) -> Cont<R, B>) -> Cont<R, B> {
    return Cont({ k in c.run({ a in f(a).run(k) }) })
}

public func fmap<R, A, B>(c : Cont<R, A>, f : @escaping (A) -> B) -> Cont<R, B> {
    return Cont({ k in c.run({ a in k(f(a)) }) })
}

public func callcc<R, A, B>(_ f : @escaping (@escaping (A) -> Cont<R, B>) -> Cont<R, A> ) -> Cont<R, A> {
    return Cont({ k in
        f({ a in
            Cont({ x in k(a) })
        }).run(k)
        
    })
}

// Examples from http://tonymorris.github.io/blog/posts/continuation-monad-in-scala/
public func square(_ n : Int) -> Int {
    return n * n
}

public func squarec<R>(_ n : Int) -> Cont<R, Int> {
    return Cont<R, Int>.pure(square(n))
}

public func squareE(_ n : Int) -> Cont<(), Int> {
    return squarec(n)
}

squareE(6)

public func div<R>(c : @escaping (String) -> Cont<R, Int>, n : Int, d : Int) -> Cont<R, Int> {
    return callcc({ ok in bind(c: callcc({ err in d == 0 ? err("Denominator 0") : ok(n / d) }), f: c) })
}

public func divError<R>(n : Int, d : Int) -> Cont<R, Int> {
    return div(c: { s in return error(s) }, n: n, d: d)
}
let printF:(Int) -> Void = {x in print(x)}
divError(n:7, d:3).run(printF)
divError(n:7, d:0).run(printF)
