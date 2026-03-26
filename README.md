Realization of case from my practice on zig. We were making reward based loyalty program and we needed to make a system for processing our partners' reports and awarding bonuses to users.
With different partners there were different afreements about points accrual. With one, for example, we should award points equal to 5% of the order amount if amount was more than 10 dollars.
We created "rules", a mini programming language to process reports flexibly according to contracts. Rule consists of a conditions that checks order compliance and an action that calculates the amount of bonus points.
We did it on golang and everything happened in a runtime. Here I made comptime compillation of rules. The rule is defined in the json file. In comptime program parses it and creates structure which could be applied to reports. Reports are also located in the json file and are processed in a runtime.
The rule structure:
{
    "if": {
        "gte": {"value": 10}
    },
    "then": {
        "multiply": {"value": 0.05}
    }
}
It is for mentioned mechanics, 5% of amount if amount more than 10.
Rule parsing occurs through an intermediate tagged unions into VTable interfaces.