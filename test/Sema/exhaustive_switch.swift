// RUN: %target-typecheck-verify-swift -swift-version 5 -enable-resilience -enable-nonfrozen-enum-exhaustivity-diagnostics

func foo(a: Int?, b: Int?) -> Int {
  switch (a, b) {
  case (.none, _): return 1
  case (_, .none): return 2
  case (.some(_), .some(_)): return 3
  }
    
  switch (a, b) {
  case (.none, _): return 1
  case (_, .none): return 2
  case (_?, _?): return 3
  }
  
  switch Optional<(Int?, Int?)>.some((a, b)) {
  case .none: return 1
  case let (_, x?)?: return x
  case let (x?, _)?: return x
  case (.none, .none)?: return 0
  }
}

func bar(a: Bool, b: Bool) -> Int {
  switch (a, b) {
  case (false, false):
    return 1
  case (true, _):
    return 2
  case (false, true):
    return 3
  }
}


enum Result<T> {
  case Ok(T)
  case Error(Error)

  func shouldWork<U>(other: Result<U>) -> Int {
    switch (self, other) { // No warning
    case (.Ok, .Ok): return 1
    case (.Error, .Error): return 2
    case (.Error, _): return 3
    case (_, .Error): return 4
    }
  }
}

enum Foo {
  case A(Int)
  case B(Int)
}
func foo() {
  switch (Foo.A(1), Foo.B(1)) {
  case (.A(_), .A(_)):
    ()
  case (.B(_), _):
    ()
  case (_, .B(_)):
    ()
  }
  
  switch (Foo.A(1), Optional<(Int, Int)>.some((0, 0))) {
  case (.A(_), _):
    break
  case (.B(_), (let q, _)?):
    print(q)
  case (.B(_), nil):
    break
  }
}

class C {}

enum Bar {
  case TheCase(C?)
}

func test(f: Bar) -> Bool {
  switch f {
  case .TheCase(_?):
    return true
  case .TheCase(nil):
    return false
  }
}

func op(this : Optional<Bool>, other : Optional<Bool>) -> Optional<Bool> {
  switch (this, other) { // No warning
  case let (.none, w):
    return w
  case let (w, .none):
    return w
  case let (.some(e1), .some(e2)):
    return .some(e1 && e2)
  }
}

enum Threepeat {
  case a, b, c
}

func test3(x: Threepeat, y: Threepeat) {
  switch (x, y) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 {{add missing case: '(.a, .c)'}}
  case (.a, .a):
    ()
  case (.b, _):
    ()
  case (.c, _):
    ()
  case (_, .b):
    ()
  }
}

enum A {
  case A(Int)
  case B(Bool)
  case C
  case D
}

enum B {
  case A
  case B
}

func s(a: A, b: B) {
  switch (a, b) {
  case (.A(_), .A):
    break
  case (.A(_), .B):
    break

  case (.B(_), let b):
  // expected-warning@-1 {{immutable value 'b' was never used; consider replacing with '_' or removing it}}
    break

  case (.C, _), (.D, _):
    break
  }
}


enum Grimble {
  case A
  case B
  case C
}

enum Gromble {
  case D
  case E
}

func doSomething(foo:Grimble, bar:Gromble) {
  switch(foo, bar) { // No warning
  case (.A, .D):
    break
  case (.A, .E):
    break
  case (.B, _):
    break
  case (.C, _):
    break
  }
}

enum E {
  case A
  case B
}

func f(l: E, r: E) {
  switch (l, r) {
  case (.A, .A):
    return
  case (.A, _):
    return
  case (_, .A):
    return
  case (.B, .B):
    return
  }
}

enum TestEnum {
  case A, B
}

func switchOverEnum(testEnumTuple: (TestEnum, TestEnum)) {

  switch testEnumTuple {
  case (_,.B):
    // Matches (.A, .B) and (.B, .B)
    break
  case (.A,_):
    // Matches (.A, .A)
    // Would also match (.A, .B) but first case takes precedent
    break
  case (.B,.A):
    // Matches (.B, .A)
    break
  }

}

func tests(a: Int?, b: String?) {
  switch (a, b) {
  case let (.some(n), _): print("a: ", n, "?")
  case (.none, _): print("Nothing", "?")
  }

  switch (a, b) {
  case let (.some(n), .some(s)): print("a: ", n, "b: ", s)
  case let (.some(n), .none): print("a: ", n, "Nothing")
  case (.none, _): print("Nothing")
  }

  switch (a, b) {
  case let (.some(n), .some(s)): print("a: ", n, "b: ", s)
  case let (.some(n), .none): print("a: ", n, "Nothing")
  case let (.none, .some(s)): print("Nothing", "b: ", s)
  case (.none, _): print("Nothing", "?")
  }

  switch (a, b) {
  case let (.some(n), .some(s)): print("a: ", n, "b: ", s)
  case let (.some(n), .none): print("a: ", n, "Nothing")
  case let (.none, .some(s)): print("Nothing", "b: ", s)
  case (.none, .none): print("Nothing", "Nothing")
  }

}

enum X {
  case Empty
  case A(Int)
  case B(Int)
}

func f(a: X, b: X) {
  switch (a, b) {
  case (_, .Empty): ()
  case (.Empty, _): ()

  case (.A, .A): ()
  case (.B, .B): ()

  case (.A, .B): ()
  case (.B, .A): ()

  }
}

func f2(a: X, b: X) {
  switch (a, b) {

  case (.A, .A): ()
  case (.B, .B): ()

  case (.A, .B): ()
  case (.B, .A): ()

  case (_, .Empty): ()
  case (.Empty, _): ()

  case (.A, .A): () // expected-warning {{case is already handled by previous patterns; consider removing it}}
  case (.B, .B): () // expected-warning {{case is already handled by previous patterns; consider removing it}}

  case (.A, .B): () // expected-warning {{case is already handled by previous patterns; consider removing it}}
  case (.B, .A): () // expected-warning {{case is already handled by previous patterns; consider removing it}}

  default: ()
  }
}

enum XX : Int {
  case A
  case B
  case C
  case D
  case E
}

func switcheroo(a: XX, b: XX) -> Int {
  switch(a, b) { // No warning
  case (.A, _)  : return 1
  case (_, .A)  : return 2

  case (.C, _)  : return 3
  case (_, .C)  : return 4

  case (.B, .B) : return 5
  case (.B, .D) : return 6
  case (.D, .B) : return 7

  case (.B, .E) : return 8
  case (.E, .B) : return 9

  case (.E, _)  : return 10
  case (_, .E)  : return 11
  case (.D, .D) : return 12

  default:
    print("never hits this:", a, b)
    return 13
  }
}

enum PatternCasts {
  case one(Any)
  case two
}

func checkPatternCasts() {
  // Pattern casts with this structure shouldn't warn about duplicate cases.
  let x: PatternCasts = .one("One")
  switch x {
  case .one(let s as String): print(s)
  case .one: break
  case .two: break
  }

  // But should warn here.
  switch x {
  case .one(_): print(s)
  case .one: break // expected-warning {{case is already handled by previous patterns; consider removing it}}
  case .two: break
  }
}

enum MyNever {}
func ~= (_ : MyNever, _ : MyNever) -> Bool { return true }
func myFatalError() -> MyNever { fatalError() }

func checkUninhabited() {
  // Scrutinees of uninhabited type may match any number and kind of patterns
  // that Sema is willing to accept at will.  After all, it's quite a feat to
  // productively inhabit the type of crashing programs.
  func test1(x : Never) {
    switch x {} // No diagnostic.
  }
  
  func test2(x : Never) {
    switch (x, x) {} // No diagnostic.
  }
  
  func test3(x : MyNever) {
    switch x { // No diagnostic.
    case myFatalError(): break
    case myFatalError(): break
    case myFatalError(): break
    }
  }
}

enum Runcible {
  case spoon
  case hat
  case fork
}

func checkDiagnosticMinimality(x: Runcible?) {
  switch (x!, x!) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 {{add missing case: '(.fork, _)'}}
  // expected-note@-2 {{add missing case: '(.hat, .hat)'}}
  // expected-note@-3 {{add missing case: '(.hat, .fork)'}}
  // expected-note@-4 {{add missing case: '(_, .fork)'}}
  case (.spoon, .spoon):
    break
  case (.spoon, .hat):
    break
  case (.hat, .spoon):
    break
  }

  switch (x!, x!) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 {{add missing case: '(.fork, _)'}}
  // expected-note@-2 {{add missing case: '(.hat, .spoon)'}}
  // expected-note@-3 {{add missing case: '(.hat, .fork)'}}
  // expected-note@-4 {{add missing case: '(.spoon, .hat)'}}
  // expected-note@-5 {{add missing case: '(.spoon, .fork)'}}
  // expected-note@-6 {{add missing case: '(_, .fork)'}}
  case (.spoon, .spoon):
    break
  case (.hat, .hat):
    break
  }
}

enum LargeSpaceEnum {
  case case0
  case case1
  case case2
  case case3
  case case4
  case case5
  case case6
  case case7
  case case8
  case case9
  case case10
}

func notQuiteBigEnough() -> Bool {
  switch (LargeSpaceEnum.case1, LargeSpaceEnum.case2) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 110 {{add missing case:}}
  case (.case0, .case0): return true
  case (.case1, .case1): return true
  case (.case2, .case2): return true
  case (.case3, .case3): return true
  case (.case4, .case4): return true
  case (.case5, .case5): return true
  case (.case6, .case6): return true
  case (.case7, .case7): return true
  case (.case8, .case8): return true
  case (.case9, .case9): return true
  case (.case10, .case10): return true
  }
}

enum OverlyLargeSpaceEnum {
  case case0
  case case1
  case case2
  case case3
  case case4
  case case5
  case case6
  case case7
  case case8
  case case9
  case case10
  case case11
}

enum ContainsOverlyLargeEnum {
  case one(OverlyLargeSpaceEnum)
  case two(OverlyLargeSpaceEnum)
  case three(OverlyLargeSpaceEnum, OverlyLargeSpaceEnum)
}

func quiteBigEnough() -> Bool {
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 {{do you want to add a default clause?}}
  case (.case0, .case0): return true
  case (.case1, .case1): return true
  case (.case2, .case2): return true
  case (.case3, .case3): return true
  case (.case4, .case4): return true
  case (.case5, .case5): return true
  case (.case6, .case6): return true
  case (.case7, .case7): return true
  case (.case8, .case8): return true
  case (.case9, .case9): return true
  case (.case10, .case10): return true
  case (.case11, .case11): return true
  }

  // No diagnostic
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 {{do you want to add a default clause?}}
  case (.case0, _): return true
  case (.case1, _): return true
  case (.case2, _): return true
  case (.case3, _): return true
  case (.case4, _): return true
  case (.case5, _): return true
  case (.case6, _): return true
  case (.case7, _): return true
  case (.case8, _): return true
  case (.case9, _): return true
  case (.case10, _): return true
  }


  // No diagnostic
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) {
  case (.case0, _): return true
  case (.case1, _): return true
  case (.case2, _): return true
  case (.case3, _): return true
  case (.case4, _): return true
  case (.case5, _): return true
  case (.case6, _): return true
  case (.case7, _): return true
  case (.case8, _): return true
  case (.case9, _): return true
  case (.case10, _): return true
  case (.case11, _): return true
  }

  // No diagnostic
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) {
  case (_, .case0): return true
  case (_, .case1): return true
  case (_, .case2): return true
  case (_, .case3): return true
  case (_, .case4): return true
  case (_, .case5): return true
  case (_, .case6): return true
  case (_, .case7): return true
  case (_, .case8): return true
  case (_, .case9): return true
  case (_, .case10): return true
  case (_, .case11): return true
  }

  // No diagnostic
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) {
  case (_, _): return true
  }

  // No diagnostic
  switch (OverlyLargeSpaceEnum.case1, OverlyLargeSpaceEnum.case2) {
  case (.case0, .case0): return true
  case (.case1, .case1): return true
  case (.case2, .case2): return true
  case (.case3, .case3): return true
  case _: return true
  }
  
  // No diagnostic
  switch ContainsOverlyLargeEnum.one(.case0) {
  case .one: return true
  case .two: return true
  case .three: return true
  }
}

indirect enum InfinitelySized {
  case one
  case two
  case recur(InfinitelySized)
  case mutualRecur(MutuallyRecursive, InfinitelySized)
}

indirect enum MutuallyRecursive {
  case one
  case two
  case recur(MutuallyRecursive)
  case mutualRecur(InfinitelySized, MutuallyRecursive)
}

func infinitelySized() -> Bool {
  switch (InfinitelySized.one, InfinitelySized.one) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 10 {{add missing case:}}
  case (.one, .one): return true
  case (.two, .two): return true
  }
  
  switch (MutuallyRecursive.one, MutuallyRecursive.one) { // expected-error {{switch must be exhaustive}}
  // expected-note@-1 10 {{add missing case:}}
  case (.one, .one): return true
  case (.two, .two): return true
  }
}

func diagnoseDuplicateLiterals() {
  let str = "def"
  let int = 2
  let dbl = 2.5

  // No Diagnostics
  switch str {
  case "abc": break
  case "def": break
  case "ghi": break
  default: break
  }

  switch str {
  case "abc": break
  case "def": break // expected-note {{first occurrence of identical literal pattern is here}}
  case "def": break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case "ghi": break
  default: break
  }
  
  switch str {
  case "abc", "def": break // expected-note 2 {{first occurrence of identical literal pattern is here}}
  case "ghi", "jkl": break
  case "abc", "def": break // expected-warning 2 {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  switch str {
  case "xyz": break // expected-note {{first occurrence of identical literal pattern is here}}
  case "ghi": break
  case "def": break
  case "abc": break
  case "xyz": break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  func someStr() -> String { return "sdlkj" }
  let otherStr = "ifnvbnwe"
  switch str {
  case "sdlkj": break
  case "ghi": break // expected-note {{first occurrence of identical literal pattern is here}}
  case someStr(): break
  case "def": break
  case otherStr: break
  case "xyz": break // expected-note {{first occurrence of identical literal pattern is here}}
  case "ifnvbnwe": break
  case "ghi": break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case "xyz": break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  // No Diagnostics
  switch int {
  case -2: break
  case -1: break
  case 0: break
  case 1: break
  case 2: break
  case 3: break
  default: break
  }

  switch int {
  case -2: break // expected-note {{first occurrence of identical literal pattern is here}}
  case -2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 1: break
  case 2: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 3: break
  default: break
  }
    
  switch int {
  case -2, -2: break // expected-note {{first occurrence of identical literal pattern is here}} expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 1, 2: break // expected-note 3 {{first occurrence of identical literal pattern is here}}
  case 2, 3: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 1, 2: break // expected-warning 2 {{literal value is already handled by previous pattern; consider removing it}}
  case 4, 5: break
  case 7, 7: break // expected-note {{first occurrence of identical literal pattern is here}}
                   // expected-warning@-1 {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  switch int {
  case 1: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 2: break // expected-note 2 {{first occurrence of identical literal pattern is here}}
  case 3: break
  case 17: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 4: break
  case 2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 001: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 5: break
  case 0x11: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 0b10: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  switch int {
  case 10: break
  case 0b10: break // expected-note {{first occurrence of identical literal pattern is here}}
  case -0b10: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 3000: break
  case 0x12: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 400: break
  case 2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case -2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 18: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }

  func someInt() -> Int { return 0x1234 }
  let otherInt = 13254
  switch int {
  case 13254: break
  case 3000: break
  case 00000002: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 0x1234: break
  case someInt(): break
  case 400: break
  case 2: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 18: break
  case otherInt: break
  case 230: break
  default: break
  }

  // No Diagnostics
  switch dbl {
  case -3.5: break
  case -2.5: break
  case -1.5: break
  case 1.5: break
  case 2.5: break
  case 3.5: break
  default: break
  }
  
  switch dbl {
  case -3.5: break
  case -2.5: break // expected-note {{first occurrence of identical literal pattern is here}}
  case -2.5: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case -1.5: break
  case 1.5: break
  case 2.5: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 2.5: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 3.5: break
  default: break
  }
  
  switch dbl {
  case 1.5, 4.5, 7.5, 6.9: break // expected-note 2 {{first occurrence of identical literal pattern is here}}
  case 3.4, 1.5: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 7.5, 2.3: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }
  
  switch dbl {
  case 1: break
  case 1.5: break // expected-note 2 {{first occurrence of identical literal pattern is here}}
  case 2.5: break
  case 3.5: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 5.3132: break
  case 1.500: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 46.2395: break
  case 1.5000: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 0003.50000: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 23452.43: break
  default: break
  }
  
  func someDouble() -> Double { return 324.4523 }
  let otherDouble = 458.2345
  switch dbl {
  case 1: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 1.5: break
  case 2.5: break
  case 3.5: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 5.3132: break
  case 46.2395: break
  case someDouble(): break
  case 0003.50000: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case otherDouble: break
  case 2.50505: break // expected-note {{first occurrence of identical literal pattern is here}}
  case 23452.43: break
  case 00001: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  case 123453: break
  case 2.50505000000: break // expected-warning {{literal value is already handled by previous pattern; consider removing it}}
  default: break
  }
}

func checkLiteralTuples() {
  let str1 = "abc"
  let str2 = "def"
  let int1 = 23
  let int2 = 7
  let dbl1 = 4.23
  let dbl2 = 23.45
  
  // No Diagnostics
  switch (str1, str2) {
  case ("abc", "def"): break
  case ("def", "ghi"): break
  case ("ghi", "def"): break
  case ("abc", "def"): break // We currently don't catch this
  default: break
  }
  
  // No Diagnostics
  switch (int1, int2) {
  case (94, 23): break
  case (7, 23): break
  case (94, 23): break // We currently don't catch this
  case (23, 7): break
  default: break
  }
  
  // No Diagnostics
  switch (dbl1, dbl2) {
  case (543.21, 123.45): break
  case (543.21, 123.45): break // We currently don't catch this
  case (23.45, 4.23): break
  case (4.23, 23.45): break
  default: break
  }
}

func sr6975() {
  enum E {
    case a, b
  }

  let e = E.b
  switch e {
  case .a as E: // expected-warning {{'as' test is always true}}
    print("a")
  case .b: // Valid!
    print("b")
  case .a: // expected-warning {{case is already handled by previous patterns; consider removing it}}
    print("second a")
  }

  func foo(_ str: String) -> Int {
    switch str { // expected-error {{switch must be exhaustive}}
    // expected-note@-1 {{do you want to add a default clause?}}
    case let (x as Int) as Any:
      return x
    }
  }
  _ = foo("wtf")
}

public enum NonExhaustive {
  case a, b
}

@_frozen public enum TemporalProxy {
  case seconds(Int)
  case milliseconds(Int)
  case microseconds(Int)
  case nanoseconds(Int)
  @_downgrade_exhaustivity_check
  case never
}

// Inlinable code is considered "outside" the module and must include a default
// case.
@inlinable
public func testNonExhaustive(_ value: NonExhaustive, for interval: TemporalProxy, flag: Bool) {
  switch value { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{do you want to add a default clause?}} {{3-3=default:\n<#code#>\n}}
  case .a: break
  }

  switch value { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{do you want to add a default clause?}} {{3-3=default:\n<#code#>\n}}
  case .a: break
  case .b: break
  }
  
  switch value {
  case .a: break
  case .b: break
  default: break // no-warning
  }

  // Test being part of other spaces.
  switch value as Optional { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{add missing case: '.some(_)'}}
  case .a?: break
  case .b?: break
  case nil: break
  }

  switch value as Optional {
  case _?: break
  case nil: break
  } // no-warning

  switch (value, flag) { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{add missing case: '(_, false)'}}
  case (.a, _): break
  case (.b, false): break
  case (_, true): break
  }

  switch (flag, value) { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{add missing case: '(false, _)'}}
  case (_, .a): break
  case (false, .b): break
  case (true, _): break
  }

  // Test interaction with @_downgrade_exhaustivity_check.
  switch (value, interval) { // expected-error {{switch must be exhaustive}} {{none}}
  // expected-note@-1 {{add missing case: '(_, .milliseconds(_))'}}
  // expected-note@-2 {{add missing case: '(_, .microseconds(_))'}}
  // expected-note@-3 {{add missing case: '(_, .nanoseconds(_))'}}
  // expected-note@-4 {{add missing case: '(_, .never)'}}
  case (_, .seconds): break
  case (.a, _): break
  case (.b, _): break
  }

  switch (value, interval) { // expected-error {{switch must be exhaustive}} {{none}}
  // expected-note@-1 {{add missing case: '(_, .seconds(_))'}}
  // expected-note@-2 {{add missing case: '(_, .milliseconds(_))'}}
  // expected-note@-3 {{add missing case: '(_, .microseconds(_))'}}
  // expected-note@-4 {{add missing case: '(_, .nanoseconds(_))'}}
  case (_, .never): break
  case (.a, _): break
  case (.b, _): break
  }
}

public func testNonExhaustiveWithinModule(_ value: NonExhaustive, for interval: TemporalProxy, flag: Bool) {
  switch value { // expected-error {{switch must be exhaustive}} {{none}} expected-note {{add missing case: '.b'}}
  case .a: break
  }

  switch value { // no-warning
  case .a: break
  case .b: break
  }
  
  switch value {
  case .a: break
  case .b: break
  default: break // no-warning
  }

  // Test being part of other spaces.
  switch value as Optional { // no-warning
  case .a?: break
  case .b?: break
  case nil: break
  }

  switch value as Optional {
  case _?: break
  case nil: break
  } // no-warning

  switch (value, flag) { // no-warning
  case (.a, _): break
  case (.b, false): break
  case (_, true): break
  }

  switch (flag, value) { // no-warning
  case (_, .a): break
  case (false, .b): break
  case (true, _): break
  }

  // Test interaction with @_downgrade_exhaustivity_check.
  switch (value, interval) { // no-warning
  case (_, .seconds): break
  case (.a, _): break
  case (.b, _): break
  }

  switch (value, interval) { // no-warning
  case (_, .never): break
  case (.a, _): break
  case (.b, _): break
  }
}
