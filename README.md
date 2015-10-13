# Digixbot Solidity Contracts for Ethereum

![DigixBot at your service](http://i.imgur.com/kKKP2xj.jpg)


## Contents

**DigixbotConfiguration**: Top-level configuration
**DigixbotUsers**: User registry
**DigixbotEthereum**: Ethereum wallet contract
**Digixbot**: Main interface contract used by the Digixbot service

## Features

* Multi-currency Support
* All transactions are executed on-chain

## Deployment Instructions

1. Create a config.yml (see examples)
2. Make sure that you have a running geth node (testnet or mainnet)
3. Run the rake task

```
rake contracts:deploy
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DigixGlobal/digixbot-contracts. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

