module overmind::birthday_bot {
    use aptos_std::table::Table;
    use std::signer;
    // use std::error;
    use aptos_framework::account;
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_std::table;
    use aptos_framework::timestamp;

    //
    // Errors
    //
    const ERROR_DISTRIBUTION_STORE_EXIST: u64 = 0;
    const ERROR_DISTRIBUTION_STORE_DOES_NOT_EXIST: u64 = 1;
    const ERROR_LENGTHS_NOT_EQUAL: u64 = 2;
    const ERROR_BIRTHDAY_GIFT_DOES_NOT_EXIST: u64 = 3;
    const ERROR_BIRTHDAY_TIMESTAMP_SECONDS_HAS_NOT_PASSED: u64 = 4;

    //
    // Data structures
    //
    struct BirthdayGift has drop, store {
        amount: u64,
        birthday_timestamp_seconds: u64,
    }

    struct DistributionStore has key {
        birthday_gifts: Table<address, BirthdayGift>,
        signer_capability: account::SignerCapability,
    }

    //
    // Assert functions
    //
    public fun assert_distribution_store_exists(
        account_address: address,
    ) {
        // TODO: assert that `DistributionStore` exists
        assert!(exists<DistributionStore>(account_address), ERROR_DISTRIBUTION_STORE_DOES_NOT_EXIST);
    }

    public fun assert_distribution_store_does_not_exist(
        account_address: address,
    ) {
        // TODO: assert that `DistributionStore` does not exist
        assert!(!exists<DistributionStore>(account_address), ERROR_DISTRIBUTION_STORE_EXIST);
    }

    public fun assert_lengths_are_equal(
        addresses: vector<address>,
        amounts: vector<u64>,
        timestamps: vector<u64>
    ) {
        // TODO: assert that the lengths of `addresses`, `amounts`, and `timestamps` are all equal
        let address_len = vector::length(&addresses);
        let amounts_len = vector::length(&amounts);
        let timestamp_len = vector::length(&timestamps);

        assert!(address_len == amounts_len, ERROR_LENGTHS_NOT_EQUAL);
        assert!(address_len == timestamp_len, ERROR_LENGTHS_NOT_EQUAL);
    }

    public fun assert_birthday_gift_exists(
        distribution_address: address,
        _address: address,
    ) acquires DistributionStore {
        // TODO: assert that `birthday_gifts` exists
        let store = borrow_global<DistributionStore>(distribution_address);
        let addr  = _address;
        assert!(table::contains(&store.birthday_gifts, addr), ERROR_BIRTHDAY_GIFT_DOES_NOT_EXIST);
    }

    public fun assert_birthday_timestamp_seconds_has_passed(
        distribution_address: address,
        address_: address,
    ) acquires DistributionStore {
        // TODO: assert that the current timestamp is greater than or equal to `birthday_timestamp_seconds`
        let store = borrow_global<DistributionStore>(distribution_address);
        // assert_birthday_gift_exists(distribution_address, address_);
        let birthdayGift = table::borrow(&store.birthday_gifts, address_);
        assert!(timestamp::now_seconds() >= birthdayGift.birthday_timestamp_seconds, ERROR_BIRTHDAY_TIMESTAMP_SECONDS_HAS_NOT_PASSED);
    }

    fun get_resource_account_by_cap(addr : address) : signer acquires DistributionStore{
        let store = borrow_global<DistributionStore>(addr);
        account::create_signer_with_capability(&store.signer_capability)
    }

    //
    // Entry functions
    //
    /**
    * Initializes birthday gift distribution contract
    * @param account - account signer executing the function
    * @param addresses - list of addresses that can claim their birthday gifts
    * @param amounts  - list of amounts for birthday gifts
    * @param birthday_timestamps - list of birthday timestamps in seconds (only claimable after this timestamp has passed)
    **/
    public entry fun initialize_distribution(
        account: &signer,
        addresses: vector<address>,
        amounts: vector<u64>,
        birthday_timestamps: vector<u64>
    )  {
        // TODO: check `DistributionStore` does not exist
        assert_distribution_store_does_not_exist(signer::address_of(account));
        // TODO: check all lengths of `addresses`, `amounts`, and `birthday_timestamps` are equal
        assert_lengths_are_equal(addresses, amounts, birthday_timestamps);
        // TODO: create resource account
        let (resource_signer, signer_cap) = account::create_resource_account(account, x"01");
        // TODO: register Aptos coin to resource account
        coin::register<AptosCoin>(&resource_signer);
        // TODO: loop through the lists and push items to birthday_gifts table
        let vlen = vector::length(&addresses);
        let idx = 0;
        let birthday_gifts = table::new();
        let total = 0;
        while (idx < vlen) {
            let address_ = vector::borrow(&addresses, idx);
            let amount = vector::borrow(&amounts, idx);
            let birthday_timestamp = vector::borrow(&birthday_timestamps, idx);
            total = total + *amount;
            table::add(&mut birthday_gifts, *address_, BirthdayGift {
                amount: *amount,
                birthday_timestamp_seconds: *birthday_timestamp
            });
            idx = idx + 1;
        };
        // TODO: transfer the sum of all items in `amounts` from initiator to resource account
        coin::transfer<AptosCoin>(account, signer::address_of(&resource_signer), total);
        // TODO: move_to resource `DistributionStore` to account signer
        move_to<DistributionStore>(account, DistributionStore{
            birthday_gifts : birthday_gifts,
            signer_capability : signer_cap
        })
    }

    /**
    * Add birthday gift to `DistributionStore.birthday_gifts`
    * @param account - account signer executing the function
    * @param address - address that can claim the birthday gift
    * @param amount  - amount for the birthday gift
    * @param birthday_timestamp_seconds - birthday timestamp in seconds (only claimable after this timestamp has passed)
    **/
    public entry fun add_birthday_gift(
        account: &signer,
        address: address,
        amount: u64,
        birthday_timestamp_seconds: u64
    ) acquires DistributionStore {
        // TODO: check that the distribution store exists
        let account_addr = signer::address_of(account);
        assert_distribution_store_exists(account_addr);
        // TODO: set new birthday gift to new `amount` and `birthday_timestamp_seconds` (birthday_gift already exists, sum `amounts` and override the `birthday_timestamp_seconds`
        let resource_signer = get_resource_account_by_cap(account_addr);
        let store = borrow_global_mut<DistributionStore>(account_addr);
        table::add(&mut store.birthday_gifts, address, BirthdayGift {
                amount: amount,
                birthday_timestamp_seconds: birthday_timestamp_seconds
            });
        // TODO: transfer the `amount` from initiator to resource account
        coin::transfer<AptosCoin>(account, signer::address_of(&resource_signer), amount);
    }

    /**
    * Remove birthday gift from `DistributionStore.birthday_gifts`
    * @param account - account signer executing the function
    * @param address - `birthday_gifts` address
    **/
    public entry fun remove_birthday_gift(
        account: &signer,
        address: address,
    ) acquires DistributionStore {
        // TODO: check that the distribution store exists
        assert_distribution_store_exists(signer::address_of(account));
        // TODO: if `birthday_gifts` exists, remove `birthday_gift` from table and transfer `amount` from resource account to initiator
        assert_birthday_gift_exists(signer::address_of(account), address);
        let resource_signer = get_resource_account_by_cap(signer::address_of(account));
        let store = borrow_global_mut<DistributionStore>(signer::address_of(account));
        let birday_gift = table::borrow(&store.birthday_gifts, address);
        coin::transfer<AptosCoin>(&resource_signer, signer::address_of(account), birday_gift.amount);
        table::remove(&mut store.birthday_gifts, address);

    }

    /**
    * Claim birthday gift from `DistributionStore.birthday_gifts`
    * @param account - account signer executing the function
    * @param distribution_address - distribution contract address
    **/
    public entry fun claim_birthday_gift(
        account: &signer,
        distribution_address: address,
    ) acquires DistributionStore {
        // TODO: check that the distribution store exists
        assert_distribution_store_exists(distribution_address);
        // TODO: check that the `birthday_gift` exists
        assert_birthday_gift_exists(distribution_address, signer::address_of(account));
        // TODO: check that the `birthday_timestamp_seconds` has passed
        assert_birthday_timestamp_seconds_has_passed(distribution_address, signer::address_of(account));
        // TODO: remove `birthday_gift` from table and transfer `amount` from resource account to initiator
        let resource_signer = get_resource_account_by_cap(distribution_address);
        let store = borrow_global_mut<DistributionStore>(distribution_address);
        let birday_gift = table::borrow(&store.birthday_gifts, signer::address_of(account));
        coin::transfer<AptosCoin>(&resource_signer, signer::address_of(account), birday_gift.amount);
        table::remove(&mut store.birthday_gifts, signer::address_of(account));
    }
}
