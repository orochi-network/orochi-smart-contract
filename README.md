# infrastructure

Infrastructure of DKDAO

```
{
    "title": "Asset Metadata",
    "type": "object",
    "properties": {
        "name": {
            "type": "string",
            "description": "Identifies the asset to which this NFT represents"
        },
        "description": {
            "type": "string",
            "description": "Describes the asset to which this NFT represents"
        },
        "image": {
            "type": "string",
            "description": "A URI pointing to a resource with mime type image/* representing the asset to which this NFT represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
        }
    }
}
```

## BSC Network

```
	RecordSet(Infrastructure, Oracle, 0xe3d3dE8B63cE45e05cb2D746d45922591f3DD08D)
	RecordSet(Infrastructure, RNG, 0xc0D409093C76DBdA83cD432D41715D9cA71E6216)
	RecordSet(Duelist King, Operator, 0xCEb82E81743a30419b6131C2284f5580Bac99114)
	RecordSet(Duelist King, Oracle, 0xFA5F881b6712637629ED0C4b79DaB20C4147f86B)
	RecordSet(Duelist King, Distributor, 0x57cB34Ac43Aa5b232e46c8b7DFcFe488c80D7259)
	RecordSet(Duelist King, Merchant, 0x54f8fbc961db8c4ECcd946526F648e58E9cC85b0)
	RecordSet(Duelist King, Sales Agent, 0x74f453DB88C774357579C7500956069cE348fE24)
	RecordSet(Duelist King, Migrator, 0x3AFe5b5085d08F168741B4C7Fe9B3a58F7FDB1d0)
	RecordSet(Duelist King, NFT Card, 0xb115a074AE430Ac459c517B826bD227372C01A98)
	RecordSet(Duelist King, NFT Item, 0xe2f0c8f0F80D3a1f0a66Eb3ab229c4f63CCd11d0)
	ListAddress(0x74f453DB88C774357579C7500956069cE348fE24)
	ListAddress(0x74f453DB88C774357579C7500956069cE348fE24)
	ListAddress(0x74f453DB88C774357579C7500956069cE348fE24)
	RecordSet(Infrastructure, Operator, 0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4)
	RecordSet(Duelist King, Operator, 0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4)
[Report for network: binance] --------------------------------------------------------
	Infrastructure/Registry:                         0x3a2a0B5A8e260bD0c2E8cf3EAA706acD0C832763
	Infrastructure/OracleProxy:                      0xe3d3dE8B63cE45e05cb2D746d45922591f3DD08D
	Infrastructure/RNG:                              0xc0D409093C76DBdA83cD432D41715D9cA71E6216
	Duelist King/OracleProxy:                        0xFA5F881b6712637629ED0C4b79DaB20C4147f86B
	Migrator/OracleProxy:                            0x3AFe5b5085d08F168741B4C7Fe9B3a58F7FDB1d0
	Duelist King/DuelistKingDistributor:             0x57cB34Ac43Aa5b232e46c8b7DFcFe488c80D7259
	Duelist King Card/NFT:                           0xb115a074AE430Ac459c517B826bD227372C01A98
	Duelist King Item/NFT:                           0xe2f0c8f0F80D3a1f0a66Eb3ab229c4f63CCd11d0
	Duelist King/DuelistKingMerchant:                0x54f8fbc961db8c4ECcd946526F648e58E9cC85b0
[End of Report for network: binance] -------------------------------------------------
Sales Agent:   0x74f453DB88C774357579C7500956069cE348fE24
Migrator:   0x74f453DB88C774357579C7500956069cE348fE24
Infrastructure Operator:   0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4
Infrastructure Oracles:    0x74f453DB88C774357579C7500956069cE348fE24
Duelist King Operator:     0xb21B3d626C66E1B932EBc8E124FE3674f7a954b4
Duelist King Oracles:      0x74f453DB88C774357579C7500956069cE348fE24
```

## Fantom

```
Libraries/Bytes 0x0ccFA3DDfdaA76c9D70a833A8a5791EDc67837c7
Libraries/Verifier 0xE04D614f2F484c9Df3bC9e5CE31D31737A568907
Infrastructure/Registry 0x67D734c43AF7D158018Ee228FCd365443F002405
Infrastructure/OracleProxy 0xB7dE45A768E940f071Ab3E38f9E615bD4E09BCC5
Infrastructure/Press 0xd301fE65B2Fb7E2f21ace2a646B310AC9F3C7494
Infrastructure/NFT 0x3A504BeAa9a0216b35d11DEBEeEe07462666BC3a
Infrastructure/RNG 0xDAcD5B5D97c3A3Eb6aBc7119f43CE5e2920a850B
Duelist King/OracleProxy 0xd1B2fE967F5A5fcDBd3617444AFaaC1d264d2910
Duelist King/DuelistKingDistributor 0xC28d9B8c0A99816928CAD53382430805F535EcDD

        RecordSet(Infrastructure, RNG, 0xDAcD5B5D97c3A3Eb6aBc7119f43CE5e2920a850B)
        RecordSet(Infrastructure, NFT, 0x3A504BeAa9a0216b35d11DEBEeEe07462666BC3a)
        RecordSet(Infrastructure, Press, 0xd301fE65B2Fb7E2f21ace2a646B310AC9F3C7494)
        RecordSet(Infrastructure, Oracle, 0xB7dE45A768E940f071Ab3E38f9E615bD4E09BCC5)
        RecordSet(Duelist King, Distributor, 0xC28d9B8c0A99816928CAD53382430805F535EcDD)
        RecordSet(Duelist King, Oracle, 0xd1B2fE967F5A5fcDBd3617444AFaaC1d264d2910)
        RecordSet(Duelist King, Operator, 0xB11225EaeABA312913b85a5efF3bD8A22EC37f83)
        RecordSet(Duelist King, NFT Card, 0xC44b1022f4895F3C04e965f8A82437a8B5cebB70)
        RecordSet(Duelist King, NFT Item, 0x6c375585A31718c38D4E3eb3eddbfb203f142834)
        ListAddress(0xCFCFd3bce78Dc1c2537a15FaE7dc894C1a211450)
        ListAddress(0x2124E408134D1047b1e6Baf89f2bA932C5F915D7)
[Report for network: fantom] --------------------------------------------------------
        Libraries/Bytes:                                 0x0ccFA3DDfdaA76c9D70a833A8a5791EDc67837c7
        Libraries/Verifier:                              0xE04D614f2F484c9Df3bC9e5CE31D31737A568907
        Infrastructure/Registry:                         0x67D734c43AF7D158018Ee228FCd365443F002405
        Infrastructure/OracleProxy:                      0xB7dE45A768E940f071Ab3E38f9E615bD4E09BCC5
        Infrastructure/Press:                            0xd301fE65B2Fb7E2f21ace2a646B310AC9F3C7494
        Infrastructure/NFT:                              0x3A504BeAa9a0216b35d11DEBEeEe07462666BC3a
        Infrastructure/RNG:                              0xDAcD5B5D97c3A3Eb6aBc7119f43CE5e2920a850B
        Chiro/TheDivine:                                 0x4B9fd51e5D6E6935635940532d1C5F0B11235630
        Duelist King/OracleProxy:                        0xd1B2fE967F5A5fcDBd3617444AFaaC1d264d2910
        Duelist King/DuelistKingDistributor:             0xC28d9B8c0A99816928CAD53382430805F535EcDD
[End of Report for network: fantom] -------------------------------------------------
Infrastructure Operator:   0xc9F8bdBa354B55331A6CbB8Ed61A72A5379918Ba
Infrastructure Oracles:    0xCFCFd3bce78Dc1c2537a15FaE7dc894C1a211450
Duelist King Operator:     0xB11225EaeABA312913b85a5efF3bD8A22EC37f83
Duelist King Oracles:      0x2124E408134D1047b1e6Baf89f2bA932C5F915D7
```

## Polygon

```
https://polygonscan.com/token/0xb5c01956842ce3a658109776215f86ca4fee2cbc
```

## Fantom Testnet

```
        RecordSet(Infrastructure, Oracle, 0x2021b7E0daf7DB5b4f49124C613686289B6c1e41)
        RecordSet(Infrastructure, RNG, 0xD524dcAfc011aecE1F52d0BD39ffF5Caa0828f48)
        RecordSet(Duelist King, Operator, 0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb)
        RecordSet(Duelist King, Oracle, 0x2E04124E32ED7f328e037a5ff893be396229dd6A)
        RecordSet(Duelist King, Distributor, 0xa5Db01CD26Ebd73bf149ffd8b083270f341bC2Fe)
        RecordSet(Duelist King, Merchant, 0x743C6a03e7B404Ba9A1aB8fFB8C73dCF2A7A2419)
        RecordSet(Duelist King, Sales Agent, 0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb)
        RecordSet(Duelist King, Migrator, 0xb7b54Ce1f9D83375D3EB55C8f72900450D0c7Bf3)
        RecordSet(Duelist King, NFT Card, 0x4D61B0cf37494719527c8a526D0fC68f871B192d)
        RecordSet(Duelist King, NFT Item, 0x5657F4BB6771f1b0A9461Ea4e7643bcc7c568f3f)
        ListAddress(0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f)
        ListAddress(0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f)
        ListAddress(0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f)
        RecordSet(Infrastructure, Operator, 0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb)
        RecordSet(Duelist King, Operator, 0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb)
[Report for network: testnet] --------------------------------------------------------
        Infrastructure/Registry:                         0x38cB9C7DE3f8F5C31c11FeF85a82353F70A9bB83
        Infrastructure/OracleProxy:                      0x2021b7E0daf7DB5b4f49124C613686289B6c1e41
        Infrastructure/RNG:                              0xD524dcAfc011aecE1F52d0BD39ffF5Caa0828f48
        Chiro/TheDivine:                                 0x517e2Ccb872B11B8580223a1BC1fc5B0DD4EA130
        Duelist King/OracleProxy:                        0x2E04124E32ED7f328e037a5ff893be396229dd6A
        Migrator/OracleProxy:                            0xb7b54Ce1f9D83375D3EB55C8f72900450D0c7Bf3
        Duelist King/DuelistKingDistributor:             0xa5Db01CD26Ebd73bf149ffd8b083270f341bC2Fe
        Duelist King Card/NFT:                           0x4D61B0cf37494719527c8a526D0fC68f871B192d
        Duelist King Item/NFT:                           0x5657F4BB6771f1b0A9461Ea4e7643bcc7c568f3f
        Duelist King/DuelistKingMerchant:                0x743C6a03e7B404Ba9A1aB8fFB8C73dCF2A7A2419
        Test/TestToken:                                  0x98577f84C38Bf87b3eBAb86437A0f6E0C8Bf1717
[End of Report for network: testnet] -------------------------------------------------
Sales Agent:   0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb
Migrator:   0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f
Infrastructure Operator:   0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb
Infrastructure Oracles:    0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f
Duelist King Operator:     0x7Ba5A9fA3f3BcCeE36f60F62a6Ef728C3856b8Bb
Duelist King Oracles:      0x6a42eecB0358eae3Ee4B265d6b388C2f0d08EB6f
```

Migration contract: `0xE0bcbE5F743D59cA0ffE91C351F5E63295295060`

## Deploy staking

An example of deploying new staking contract

```text
npx hardhat --network local deploy:staking --registry 0x0e870BC3D1A61b22E9ad8b168ceDB4Dc78D6699a --operator 0x9C00CccFC23c3AC90c48D37226D4E2aF2D3d3415
```
