#[test_only]
module game::guessing_game_tests {
    use std::signer;
    use std::string;
    use std::option;
    use aptos_framework::account;
    use aptos_framework::object;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset;
    use game::guessing_game;

    #[test(admin = @0x123, player = @0x456)]
    public fun test_basic_game_flow(admin: &signer, player: &signer) {
        // Setup accounts
        let admin_addr = signer::address_of(admin);
        let player_addr = signer::address_of(player);
        
        account::create_account_for_test(admin_addr);
        account::create_account_for_test(player_addr);
        
        // Create a test FA
        let constructor_ref = &object::create_sticky_object(admin_addr);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            string::utf8(b"Test Coin"),
            string::utf8(b"TEST"),
            8,
            string::utf8(b""),
            string::utf8(b""),
        );
        
        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let metadata = object::object_from_constructor_ref<fungible_asset::Metadata>(constructor_ref);
        
        // Initialize game config
        guessing_game::initialize(admin);
        
        // Allow test token
        guessing_game::set_token_allowed(admin, metadata, true);
        
        // Create a new game
        let fee = 100;
        let revenue_account = admin_addr;
        let _game_id = guessing_game::new(admin, admin_addr, metadata, fee, revenue_account);
        
        // Mint some FA for player
        let fa = fungible_asset::mint(&mint_ref, 1000);
        primary_fungible_store::deposit(player_addr, fa);
        
        // Player joins game
        guessing_game::join(player, admin_addr, 50, fee);
        
        // Check game info
        let (game_id, player_count, game_fee, _token_addr) = guessing_game::get_game_info(admin_addr);
        assert!(game_id == 1, 1);
        assert!(player_count == 1, 2);
        assert!(game_fee == fee, 3);
    }

    #[test(admin = @0x123)]
    #[expected_failure(abort_code = 4, location = game::guessing_game)] // E_TOKEN_NOT_ALLOWED
    public fun test_token_not_allowed(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        account::create_account_for_test(admin_addr);
        
        // Create a test FA but don't allow it
        let constructor_ref = &object::create_sticky_object(admin_addr);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            string::utf8(b"Test Coin"),
            string::utf8(b"TEST"),
            8,
            string::utf8(b""),
            string::utf8(b""),
        );
        
        let metadata = object::object_from_constructor_ref<fungible_asset::Metadata>(constructor_ref);
        
        // Initialize game config
        guessing_game::initialize(admin);
        
        // Try to create game with disallowed token - should fail
        let fee = 100;
        let revenue_account = admin_addr;
        let _game_id = guessing_game::new(admin, admin_addr, metadata, fee, revenue_account);
    }
} 