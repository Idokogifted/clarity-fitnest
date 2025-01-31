import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure that token transfer works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("fit-token", "mint", 
        [types.uint(1000), types.principal(wallet_1.address)], wallet_1.address),
      Tx.contractCall("fit-token", "transfer",
        [types.uint(500), types.principal(wallet_1.address), 
         types.principal(wallet_2.address)], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    assertEquals(block.height, 2);
    block.receipts[1].result.expectOk().expectBool(true);
  },
});
