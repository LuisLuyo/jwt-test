"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
require("./utils/config");
const index_1 = __importDefault(require("./routes/index"));
const app = express_1.default();
//require('dotenv').config({path: __dirname + '/.env'});
// middlewares
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: false }));
// Routes
app.use(index_1.default);
exports.default = app;
