import Foundation

/// ** TODO: Renaming **
/// [ ] Add plurals to `.equal` `.notEqual`
/// [ ] Rename `Joinable` to `Conditional` or `Condition`

struct CustomPredicate: Encodable {
    let predicate: [CustomPredicateContent]
}

struct CustomPredicateContent: Encodable {
    struct Variable: Encodable {
        let key: Int
    }

    let variable: Variable
    let expression: Expression
    let structure: Joinable
}

enum Expression: Encodable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case keyPath(String)
    case array([Expression])
    case lessThan
    case greaterThan
    case lessThanOrEqual
    case greaterThanOrEqual

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .keyPath(let string):
            let keyPathArgument = KeyPathArgument(identifier: string)
            try container.encode(keyPathArgument)
        case .array(let array):
            try container.encode(array)
        case .lessThan:
            try container.encode(LessThan())
        case .greaterThan:
            try container.encode(GreaterThan())
        case .lessThanOrEqual:
            try container.encode(LessThanOrEqual())
        case .greaterThanOrEqual:
            try container.encode(GreaterThanOrEqual())
        }
    }
}

struct GreaterThan: Encodable {
    let greaterThan: EmptyDict
    struct EmptyDict: Encodable { }
    init() { self.greaterThan = EmptyDict() }
}

struct LessThan: Encodable {
    let lessThan: EmptyDict
    struct EmptyDict: Encodable { }
    init() { self.lessThan = EmptyDict() }
}

struct GreaterThanOrEqual: Encodable {
    let greaterThanOrEqual: EmptyDict
    struct EmptyDict: Encodable { }
    init() { self.greaterThanOrEqual = EmptyDict() }
}

struct LessThanOrEqual: Encodable {
    let lessThanOrEqual: EmptyDict
    struct EmptyDict: Encodable { }
    init() { self.lessThanOrEqual = EmptyDict() }
}

indirect enum Joinable: Encodable {
    
    case equal([EquatableArgument])
    case notEqual([EquatableArgument])
    case comparison([EquatableArgument])

    case or([Joinable])
    case and([Joinable])

    case contains([EquatableArgument])
    
    case negation(Joinable)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .comparison(let array):
            let comparison = Comparison(array)
            try container.encode(comparison)
            
        case .or(let array):
            let disjunction = Disjunction(array)
            try container.encode(disjunction)

        case .and(let array):
            let conjunction = Conjunction(array)
            try container.encode(conjunction)

        case .equal(let array):
            let equal = Equal(array)
            try container.encode(equal)

        case .notEqual(let array):
            let notEqual = NotEqual(array)
            try container.encode(notEqual)

        case .contains(let array):
            let contains = Contains(array)
            try container.encode(contains)

        case .negation(let joinable):
            let negation = Negation(joinable)
            try container.encode(negation)
        }
    }
}

enum EquatableArgument: Encodable {
    case keyPath(Arguments.KeyPath.Arg)
    case stringValue
    case intValue
    case doubleValue
    case boolValue
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .keyPath(let arg):
            let keyPath = Arguments.KeyPath(arg: arg)
            try container.encode(keyPath)
            
        case .stringValue:
            let stringValue = Arguments.StringValue()
            try container.encode(stringValue)
            
        case .intValue:
            let intValue = Arguments.IntValue()
            try container.encode(intValue)

        case .doubleValue:
            let doubleValue = Arguments.DoubleValue()
            try container.encode(doubleValue)

        case .boolValue:
            let boolValue = Arguments.BoolValue()
            try container.encode(boolValue)

        }
    }
}

struct KeyPathArgument: Encodable {
    
    let identifier: String
    let root: Root
    
    struct Root: Encodable {
        let key: Int
    }
    
    init(identifier: String) {
        self.identifier = identifier
        self.root = Root(key: 1)
    }
}

struct Contains: Encodable {
    let identifier: String
    let args: [EquatableArgument]

    init(_ args: [EquatableArgument]) {
        self.identifier = "PredicateExpressions.CollectionContainsCollection"
        self.args = args
    }
}

struct Conjunction: Encodable {
    let identifier: String
    let args: [Joinable]
    
    init(_ args: [Joinable]) {
        self.identifier = "PredicateExpressions.Conjunction"
        self.args = args
    }
}

struct Disjunction: Encodable {
    let identifier: String
    let args: [Joinable]
    
    init(_ args: [Joinable]) {
        self.identifier = "PredicateExpressions.Disjunction"
        self.args = args
    }
}

struct Equal: Encodable {
    let identifier: String
    let args: [EquatableArgument]
    
    init(_ args: [EquatableArgument]) {
        self.identifier = "PredicateExpressions.Equal"
        self.args = args
    }
}

struct Comparison: Encodable {
    let identifier: String
    let args: [EquatableArgument]
    
    init(_ args: [EquatableArgument]) {
        self.identifier = "PredicateExpressions.Comparison"
        self.args = args
    }
}

struct NotEqual: Encodable {
    let identifier: String
    let args: [EquatableArgument]
    
    init(_ args: [EquatableArgument]) {
        self.identifier = "PredicateExpressions.NotEqual"
        self.args = args
    }
}

struct Negation: Encodable {
    let identifier: String
    let args: [Joinable]
    
    init(_ joinable: Joinable) {
        self.identifier = "PredicateExpressions.Negation"
        self.args = [joinable]
    }
}

struct Arguments {
    struct KeyPath: Encodable {
        let args: [Arg]
        let identifier: String
        
        enum Arg: Encodable {
            case string
            case int
            case double
            case bool
            case variable
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string:
                    try container.encode("Swift.String")
                case .int:
                    try container.encode("Swift.Int")
                case .double:
                    try container.encode("Swift.Double")
                case .bool:
                    try container.encode("Swift.Bool")
                case .variable:
                    try container.encode(Variable())
                }
            }
            
            struct Variable: Encodable {
                let identifier = "PredicateExpressions.Variable"
                let args = ["Foundation.Predicate.Input.0"]
            }
        }

        init(arg: Arg) {
            self.identifier = "PredicateExpressions.KeyPath"
            self.args = [.variable, arg]
        }
        
    }

    struct StringValue: Encodable {
        let identifier = "PredicateExpressions.Value"
        let args = ["Swift.String"]
    }

    struct IntValue: Encodable {
        let identifier = "PredicateExpressions.Value"
        let args = ["Swift.Int"]
    }

    struct DoubleValue: Encodable {
        let identifier = "PredicateExpressions.Value"
        let args = ["Swift.Double"]
    }

    struct BoolValue: Encodable {
        let identifier = "PredicateExpressions.Value"
        let args = ["Swift.Bool"]
    }
}
