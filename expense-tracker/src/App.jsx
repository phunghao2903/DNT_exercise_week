import React, { useState } from "react";
import { PieChart, Pie, Cell, Tooltip, Legend } from "recharts";

export default function ExpenseTracker() {
  const [expenses, setExpenses] = useState([]);
  const [title, setTitle] = useState("");
  const [amount, setAmount] = useState("");
  const [category, setCategory] = useState("Food");

  const categories = ["Food", "Transport", "Shopping", "Bills", "Other"];
  const colors = ["#8884d8", "#82ca9d", "#ffc658", "#ff7f7f", "#8dd1e1"];

  const addExpense = (e) => {
    e.preventDefault();
    if (!title || !amount) return;
    const newExpense = {
      id: Date.now(),
      title,
      amount: parseFloat(amount),
      category,
    };
    setExpenses([...expenses, newExpense]);
    setTitle("");
    setAmount("");
  };

  const data = categories.map((cat) => ({
    name: cat,
    value: expenses
      .filter((e) => e.category === cat)
      .reduce((acc, e) => acc + e.amount, 0),
  }));

 return (
  <div className="min-h-screen bg-gradient-to-br from-gray-900 to-gray-800 flex items-center justify-center p-6">
    {/* Card Container */}
    <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-2xl space-y-6">
      
      {/* Header */}
      <h1 className="text-3xl font-extrabold text-center text-gray-800 flex items-center justify-center gap-2">
        <span role="img" aria-label="money">💰</span> Expense Tracker
      </h1>

      {/* Form */}
      <form onSubmit={addExpense} className="space-y-4">
        <input
          type="text"
          placeholder="Expense title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-blue-400"
        />
        <input
          type="number"
          placeholder="Amount"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-blue-400"
        />
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="w-full p-3 border rounded-lg focus:ring-2 focus:ring-blue-400"
        >
          {categories.map((c) => (
            <option key={c} value={c}>{c}</option>
          ))}
        </select>
        <button
          type="submit"
          className="w-full bg-blue-500 text-white py-3 rounded-lg font-semibold hover:bg-blue-600 transition"
        >
          ➕ Add Expense
        </button>
      </form>

      {/* Expenses */}
      <div>
        <h2 className="text-xl font-semibold mb-3 text-gray-700">Expenses</h2>
        {expenses.length === 0 ? (
          <p className="text-gray-400 italic">No expenses yet</p>
        ) : (
          <ul className="divide-y max-h-40 overflow-y-auto">
            {expenses.map((exp) => (
              <li key={exp.id} className="py-2 flex justify-between text-gray-700">
                <span>
                  {exp.title} <span className="text-sm text-gray-500">({exp.category})</span>
                </span>
                <span className="font-bold text-blue-600">${exp.amount}</span>
              </li>
            ))}
          </ul>
        )}
      </div>

      {/* Chart */}
      <div>
        <h2 className="text-xl font-semibold mb-3 text-gray-700">Category Breakdown</h2>
        <div className="flex justify-center">
          <PieChart width={300} height={300}>
            <Pie
              data={data}
              cx="50%"
              cy="50%"
              labelLine={false}
              outerRadius={100}
              fill="#8884d8"
              dataKey="value"
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={colors[index % colors.length]} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </div>
      </div>
    </div>
  </div>
);


      
}
