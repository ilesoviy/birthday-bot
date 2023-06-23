module overmind::birthday_bot_test {
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    #[test_only]
    use aptos_framework::coin;
    #[test_only]
    use aptos_framework::timestamp;
    #[test_only]
    use overmind::birthday_bot::{initialize_distribution, assert_distribution_store_exists, add_birthday_gift, remove_birthday_gift, claim_birthday_gift};
    #[test_only]
    use std::signer;
    #[test_only]
    use std::vector;

    //
    // Test functions
    // Searching == test_[function_name]_[success || failture]_[reason]
    //
    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34)]
    fun test_initialize_distribution_success(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);

        coin::register<AptosCoin>(account);
        aptos_coin::mint(aptos_framework, account_address, 3000000);

        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        assert_distribution_store_exists(account_address);
        assert!(coin::balance<AptosCoin>(account_address) == 0, 0);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34)]
    #[expected_failure(abort_code = 0, location = overmind::birthday_bot)]
    fun test_initialize_distribution_failure_distribution_store_already_exists(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);

        coin::register<AptosCoin>(account);
        aptos_coin::mint(aptos_framework, account_address, 3000000);

        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34)]
    #[expected_failure(abort_code = 2, location = overmind::birthday_bot)]
    fun test_initialize_distribution_failure_not_equal_lengths(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);

        coin::register<AptosCoin>(account);
        aptos_coin::mint(aptos_framework, account_address, 3000000);

        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34, test_three = @0x56)]
    fun test_add_birthday_gift_success(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer,
        test_three: &signer
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);
        let test_three_address = signer::address_of(test_three);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);

        coin::register<AptosCoin>(account);
        aptos_coin::mint(aptos_framework, account_address, 4000000);

        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        add_birthday_gift(account, test_three_address, 1000000, timestamp::now_seconds());

        assert!(coin::balance<AptosCoin>(account_address) == 0, 0);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34)]
    fun test_remove_birthday_gift_success(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer,
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);

        coin::register<AptosCoin>(account);
        aptos_coin::mint(aptos_framework, account_address, 3000000);

        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        remove_birthday_gift(account, test_two_address);

        assert!(coin::balance<AptosCoin>(account_address) == 2000000, 0);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }

    #[test(aptos_framework = @0x1, account = @0xCAFE, test_one = @0x12, test_two = @0x34)]
    fun test_claim_birthday_gift_success(
        aptos_framework: &signer,
        account: &signer,
        test_one: &signer,
        test_two: &signer,
    ) {
        timestamp::set_time_has_started_for_testing(aptos_framework);
        let (burn_cap, mint_cap) = aptos_framework::aptos_coin::initialize_for_test(aptos_framework);

        let aptos_framework_address = signer::address_of(aptos_framework);
        let account_address = signer::address_of(account);
        let test_one_address = signer::address_of(test_one);
        let test_two_address = signer::address_of(test_two);

        account::create_account_for_test(aptos_framework_address);
        account::create_account_for_test(account_address);
        account::create_account_for_test(test_one_address);

        coin::register<AptosCoin>(account);
        coin::register<AptosCoin>(test_one);
        aptos_coin::mint(aptos_framework, account_address, 3000000);


        let addresses: vector<address> = vector::empty();
        let amounts: vector<u64> = vector::empty();
        let birthday_timestamps: vector<u64> = vector::empty();

        vector::push_back(&mut addresses, test_one_address);
        vector::push_back(&mut addresses, test_two_address);

        vector::push_back(&mut amounts, 1000000);
        vector::push_back(&mut amounts, 2000000);

        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());
        vector::push_back(&mut birthday_timestamps, timestamp::now_seconds());

        initialize_distribution(
            account,
            addresses,
            amounts,
            birthday_timestamps
        );

        timestamp::fast_forward_seconds(1);

        claim_birthday_gift(test_one, account_address);

        assert!(coin::balance<AptosCoin>(test_one_address) == 1000000, 0);

        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);
    }
}