module game::guessing_game {
    use std::signer;
    use std::vector;
    use aptos_framework::fungible_asset::{Self, FungibleAsset};
    use aptos_framework::timestamp;
    use aptos_framework::hash;

    use aptos_std::bcs;
    struct Player {
        addr: address,
        guess: u8,
    }

    struct Game<T> has key {
        admin: address,
        fee: u64,
        revenue_account: address,
        players: vector<Player>,
        pool: FungibleAsset<T>,
    }

    public fun new<T>(admin: &signer, fee: u64, revenue_account: address): address {
        let game = Game<T> {
            admin: signer::address_of(admin),
            fee,
            revenue_account,
            players: vector::empty<Player>(),
            pool: FungibleAsset.zero<T>(),
        };
        let addr = signer::address_of(admin);
        move_to(admin, game);
        addr
    }

    public fun join<T>(admin_addr: address, player: &signer, guess: u8, fee_asset: FungibleAsset<T>) acquires Game {
        assert!(guess >= 1 && guess <= 99, 1);
        let game = borrow_global_mut<Game<T>>(admin_addr);
        FungibleAsset.merge(&mut game.pool, fee_asset);
        vector::push_back(&mut game.players, Player { addr: signer::address_of(player), guess });
        if (vector::length(&game.players) == 10) {
            finalize<T>(game);
        }
    }

    fun finalize<T>(game: &mut Game<T>) acquires Game {
        let rand = pseudo_random();
        let closest_idx = find_closest(&game.players, rand);
        let winner = &game.players[closest_idx];
        let total = FungibleAsset.value(&game.pool);
        let prize = total * 95 / 100;
        let fees = total - prize;
        let liquidity_share = fees * 9 / 10;
        let revenue_share = fees - liquidity_share;
        let prize_asset = FungibleAsset.split(&mut game.pool, prize);
        FungibleAsset.deposit(winner.addr, prize_asset);
        // Placeholder: convert half of liquidity_share to APT and add to pool
        let _liq_asset = FungibleAsset.split(&mut game.pool, liquidity_share);
        // Send revenue
        let rev_asset = FungibleAsset.split(&mut game.pool, revenue_share);
        FungibleAsset.deposit(game.revenue_account, rev_asset);
        vector::destroy_empty(&mut game.players);
    }
    fun find_closest(players: &vector<Player>, target: u8): u64 {
        let mut idx = 0;
        let mut closest = 0xFF;
        let mut i = 0;
        while (i < vector::length(players)) {
            let p = &players[i];
            let diff = if (p.guess > target) p.guess - target else target - p.guess;
            if (diff < closest) {
                closest = diff;
                idx = i;
            };
            i = i + 1;
        }
        idx
    }

    fun pseudo_random(): u8 {
        let ts = timestamp::now_seconds();
        let bytes = bcs::to_bytes(&ts);
        let h = hash::sha3_256(bytes);
        let b = *vector::borrow(&h, 0);
        ((b as u64) % 99 + 1) as u8
    }
}
