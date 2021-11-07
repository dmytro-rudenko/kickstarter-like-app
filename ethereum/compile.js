/*
    This script does the following:
    1. Delete entire 'build' folder
    2. Read 'Campaign.sol' from the 'contracts folder
    3. Compile both contracts with solidity compiler
    4. Write output to the 'build' directory
*/

import { resolve } from "path";
import {
	removeSync,
	readFileSync,
	writeFileSync,
	ensureDirSync,
} from "fs-extra"; // file system access
import { compile } from "solc";

// 1. Delete entire 'build' folder
const buildPath = resolve(__dirname, "build");
removeSync(buildPath);

// 2. Read 'Campaign.sol' from the 'contracts folder
const campaignPath = resolve(__dirname, "contracts", "Campaign.sol");
const source = readFileSync(campaignPath, "utf8");

const input = {
	language: "Solidity",
	sources: {
		"Campaign.sol": {
			content: source,
		},
	},
	settings: {
		outputSelection: {
			"*": {
				"*": ["*"],
			},
		},
	},
};

console.log("Compiling the contracts...");
// 3. Compile both contracts with solidity compiler
const output = JSON.parse(compile(JSON.stringify(input)));

if (output.errors) {
	output.errors.forEach((err) => {
		console.log(err.formattedMessage);
		writeFileSync(
			resolve(buildPath, "Errors.txt"),
			err.formattedMessage,
			"utf8"
		);
	});
} else {
	const contracts = output.contracts["Campaign.sol"];
	ensureDirSync(buildPath);
	for (let contractName in contracts) {
		const contract = contracts[contractName];
		writeFileSync(
			resolve(buildPath, `${contractName}.json`),
			JSON.stringify(contract, null, 2),
			"utf8"
		);
	}
}
