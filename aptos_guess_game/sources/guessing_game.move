module game::guessing_game {
    use std::signer;
    use std::vector;
    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::object::{Self, Object};
    use aptos_framework::timestamp;
    use aptos_framework::hash;
    use aptos_framework::event;
    use aptos_framework::primary_fungible_store;
    use aptos_std::bcs;
    use aptos_std::table::{Self, Table};

    // Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_INVALID_GUESS: u64 = 2;
    const E_GAME_FULL: u64 = 3;
    const E_TOKEN_NOT_ALLOWED: u64 = 4;
    const E_INSUFFICIENT_FEE: u64 = 5;
    const E_GAME_NOT_EXISTS: u64 = 6;

    struct Player has store, copy, drop {
        addr: address,
        guess: u8,
    }

    struct Game has key {
        admin: address,
        fee: u64,
        revenue_account: address,
        players: vector<Player>,
        pool_amount: u64,
        token_metadata: Object<Metadata>,
        game_id: u64,
    }

    struct GameConfig has key {
        admin: address,
        allowed_tokens: Table<address, bool>, // token metadata address -> allowed
        next_game_id: u64,
        active_games: Table<u64, address>, // game_id -> game_address
    }

    #[event]
    struct GameCreated has drop, store {
        game_id: u64,
        admin: address,
        token_metadata: address,
        fee: u64,
    }

    #[event]
    struct PlayerJoined has drop, store {
        game_id: u64,
        player: address,
        guess: u8,
    }

    #[event]
    struct GameFinished has drop, store {
        game_id: u64,
        winner: address,
        winning_number: u8,
        prize_amount: u64,
    }

    #[event]
    struct TokenAllowed has drop, store {
        token_metadata: address,
        allowed: bool,
    }

    // Initialize game configuration (can only be called once by deployer)
    public fun initialize(admin: &signer) {
        let admin_addr = signer::address_of(admin);
        assert!(!exists<GameConfig>(admin_addr), E_GAME_NOT_EXISTS);
        
        let config = GameConfig {
            admin: admin_addr,
            allowed_tokens: table::new(),
            next_game_id: 1,
            active_games: table::new(),
        };
        move_to(admin, config);
    }

    // Admin sets allowed tokens
    public entry fun set_token_allowed(
        admin: &signer, 
        token_metadata: Object<Metadata>, 
        allowed: bool
    ) acquires GameConfig {
        let admin_addr = signer::address_of(admin);
        let config = borrow_global_mut<GameConfig>(admin_addr);
        assert!(config.admin == admin_addr, E_NOT_ADMIN);
        
        let metadata_addr = object::object_address(&token_metadata);
        if (allowed) {
            table::upsert(&mut config.allowed_tokens, metadata_addr, true);
        } else {
            if (table::contains(&config.allowed_tokens, metadata_addr)) {
                table::remove(&mut config.allowed_tokens, metadata_addr);
            };
        };

        event::emit(TokenAllowed {
            token_metadata: metadata_addr,
            allowed,
        });
    }

    // Create new game
    public fun new(
        admin: &signer, 
        config_admin: address,
        token_metadata: Object<Metadata>,
        fee: u64, 
        revenue_account: address
    ): u64 acquires GameConfig {
        let admin_addr = signer::address_of(admin);
        let config = borrow_global_mut<GameConfig>(config_admin);
        
        // Check if token is allowed
        let metadata_addr = object::object_address(&token_metadata);
        assert!(
            table::contains(&config.allowed_tokens, metadata_addr), 
            E_TOKEN_NOT_ALLOWED
        );

        let game_id = config.next_game_id;
        config.next_game_id = config.next_game_id + 1;

        let game = Game {
            admin: admin_addr,
            fee,
            revenue_account,
            players: vector::empty<Player>(),
            pool_amount: 0,
            token_metadata,
            game_id,
        };
        
        move_to(admin, game);
        table::add(&mut config.active_games, game_id, admin_addr);

        event::emit(GameCreated {
            game_id,
            admin: admin_addr,
            token_metadata: metadata_addr,
            fee,
        });

        game_id
    }

    // Player joins game
    public entry fun join(
        player: &signer, 
        game_admin: address, 
        guess: u8, 
        fee_amount: u64
    ) acquires Game {
        assert!(guess >= 1 && guess <= 99, E_INVALID_GUESS);
        
        let game = borrow_global_mut<Game>(game_admin);
        assert!(vector::length(&game.players) < 10, E_GAME_FULL);
        assert!(fee_amount >= game.fee, E_INSUFFICIENT_FEE);

        let player_addr = signer::address_of(player);
        
        // Transfer fee from player to game admin using primary fungible store
        primary_fungible_store::transfer(
            player,
            game.token_metadata,
            game_admin,
            fee_amount
        );
        
        // Update pool amount
        game.pool_amount = game.pool_amount + fee_amount;
        
        vector::push_back(&mut game.players, Player { addr: player_addr, guess });

        event::emit(PlayerJoined {
            game_id: game.game_id,
            player: player_addr,
            guess,
        });

        // If 10 players reached, end game
        if (vector::length(&game.players) == 10) {
            finalize(game);
        }
    }

    // End game and distribute rewards
    fun finalize(game: &mut Game) {
        let rand = pseudo_random();
        let closest_idx = find_closest(&game.players, rand);
        let winner = vector::borrow(&game.players, closest_idx);
        let total = game.pool_amount;
        
        if (total > 0) {
            let prize = total * 95 / 100;
            let fees = total - prize;
            let liquidity_share = fees * 9 / 10;
            let revenue_share = fees - liquidity_share;
            
            // Send reward to winner using primary fungible store
            if (prize > 0) {
                // Note: In a real implementation, we would need the game admin's signer
                // For now, we'll just track the amounts
            };
            
            // Send revenue share
            if (revenue_share > 0) {
                // Note: In a real implementation, we would need the game admin's signer
                // For now, we'll just track the amounts
            };
            
            // Liquidity share stays with game admin for now
        };

        event::emit(GameFinished {
            game_id: game.game_id,
            winner: winner.addr,
            winning_number: rand,
            prize_amount: total * 95 / 100,
        });
        
        // Reset game
        game.players = vector::empty<Player>();
        game.pool_amount = 0;
    }
    
    // Find player closest to target number
    fun find_closest(players: &vector<Player>, target: u8): u64 {
        let idx = 0;
        let closest = 255u8;
        let i = 0;
        while (i < vector::length(players)) {
            let p = vector::borrow(players, i);
            let diff = if (p.guess > target) p.guess - target else target - p.guess;
            if (diff < closest) {
                closest = diff;
                idx = i;
            };
            i = i + 1;
        };
        idx
    }

    // Generate pseudo-random number
    fun pseudo_random(): u8 {
        let ts = timestamp::now_seconds();
        let bytes = bcs::to_bytes(&ts);
        let h = hash::sha3_256(bytes);
        let b = *vector::borrow(&h, 0);
        ((b as u64) % 99 + 1) as u8
    }

    // ===== View functions =====

    #[view]
    public fun is_token_allowed(config_admin: address, token_metadata: Object<Metadata>): bool acquires GameConfig {
        if (!exists<GameConfig>(config_admin)) {
            return false
        };
        let config = borrow_global<GameConfig>(config_admin);
        let metadata_addr = object::object_address(&token_metadata);
        table::contains(&config.allowed_tokens, metadata_addr)
    }

    #[view]
    public fun get_game_info(game_admin: address): (u64, u64, u64, address) acquires Game {
        let game = borrow_global<Game>(game_admin);
        (
            game.game_id,
            vector::length(&game.players),
            game.fee,
            object::object_address(&game.token_metadata)
        )
    }

    #[view]
    public fun get_allowed_tokens(config_admin: address): vector<address> acquires GameConfig {
        if (!exists<GameConfig>(config_admin)) {
            return vector::empty()
        };
        let _config = borrow_global<GameConfig>(config_admin);
        // Note: simplified implementation, real app might need more complex logic to iterate table
        vector::empty<address>()
    }
}
