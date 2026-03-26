const std = @import("std");

// Logical operations in rule

pub const Gte = struct {
    value: f32,

    pub fn check(ptr: *anyopaque, operand: f32) bool {
        const self: *const Gte = @ptrCast(@alignCast(ptr));
        return operand > self.value;
    }

    pub const vtable = Condition.VTable{ .check = check };
};

pub const Lte = struct {
    value: f32,

    pub fn check(ptr: *anyopaque, operand: f32) bool {
        const self: *const Lte = @ptrCast(@alignCast(ptr));
        return operand < self.value;
    }

    pub const vtable = Condition.VTable{ .check = check };
};

pub const ConditionConfig = union(enum) {
    gte: Gte,
    lte: Lte,
};

pub const Condition = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    pub const VTable = struct { check: *const fn (*anyopaque, f32) bool };

    pub fn check(self: Condition, operand: f32) bool {
        return self.vtable.check(self.ptr, operand);
    }
};

// Ariphmetic operations in rule

pub const Plus = struct {
    value: f32,

    pub fn compute(ptr: *anyopaque, operand: f32) f32 {
        const self: *const Plus = @ptrCast(@alignCast(ptr));
        return operand + self.value;
    }

    pub const vtable = Action.VTable{ .compute = compute };
};

pub const Multiply = struct {
    value: f32,

    pub fn compute(ptr: *anyopaque, operand: f32) f32 {
        const self: *const Multiply = @ptrCast(@alignCast(ptr));
        return operand * self.value;
    }

    pub const vtable = Action.VTable{ .compute = compute };
};

pub const Action = struct {
    ptr: *anyopaque,
    vtable: *const VTable,
    pub const VTable = struct { compute: *const fn (*anyopaque, f32) f32 };

    pub fn compute(self: Action, operand: f32) f32 {
        return self.vtable.compute(self.ptr, operand);
    }
};

pub const ActionConfig = union(enum) {
    plus: Plus,
    multiply: Multiply,
};

pub const RuleConfig = struct {
    @"if": ConditionConfig,
    then: ActionConfig,
};

pub const Order = struct {
    id: u32,
    user_id: []const u8,
    category: []const u8,
    name: []const u8,
    brand: []const u8,
    quantity: i32,
    price: f32,
    currency: []const u8,
};

pub const PointsAccrual = struct {
    Amount: i32,
    UserId: []const u8,
};
