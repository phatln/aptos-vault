module tap::vault {
    use std::option;
    use std::option::{is_some};
    use std::signer;
    use std::signer::address_of;
    use aptos_framework::coin;
    use aptos_framework::fungible_asset;
    use aptos_framework::object::address_to_object;
    use aptos_framework::primary_fungible_store;

    public entry fun deposit<CoinType>(
        signer: &signer,
        fa_addr: 0x1::option::Option<address>,
        amount: u64) {
        if (0x1::option::is_some(&fa_addr)) {
            let fa_addr = 0x1::option::destroy_some(fa_addr);
            let fa_object = address_to_object<fungible_asset::Metadata>(fa_addr);
            let fa = 0x1::primary_fungible_store::withdraw<fungible_asset::Metadata>(signer, fa_object, amount);
            0x1::primary_fungible_store::deposit(@tap, fa);
        } else {
            let coin = coin::withdraw<CoinType>(signer, amount);
            coin::deposit(@tap, coin);
        };
    }

    public entry fun withdraw_vault<T0>(
        signer: &signer,
        fa_addr: 0x1::option::Option<address>,
        beneficiary: address,
    ) {
        if (0x1::option::is_some(&fa_addr)) {
            let fa_addr = 0x1::option::destroy_some(fa_addr);
            let fa_object = address_to_object<fungible_asset::Metadata>(fa_addr);
            let amount = 0x1::primary_fungible_store::balance(address_of(signer), fa_object);
            primary_fungible_store::transfer(signer, fa_object, beneficiary, amount);
        } else {
            let v0 = 0x1::signer::address_of(signer);
            if (!0x1::coin::is_account_registered<T0>(v0)) {
                0x1::coin::register<T0>(signer);
            };
            let amount = coin::balance<T0>(@tap);
            coin::transfer<T0>(signer, beneficiary, amount);
        }
    }
}
