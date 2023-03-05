# 交換しないと減るトークン

価値を保存できないことに意味がある、かもしれない。


0x67694893dD17A28e84d4dD911522ea09722fc18E: ConciliatorProxy
0x0eD79A21d5f72D288a1cB4bc4600A40Ce9405AeE: AccessToken
0x392657F10817a86D8c18E30C77fEa52d157156ff: OkimochiToken

## コントラクトの構成

### `ConciliatorProxy`
任意のコントラクト関数を投票ベースで呼び出すことができるコントラクト。
このコントラクトのアドレスをコントラクトのOwnerにしておけば、コミュニティの投票によって管理コマンドを実行できる。

### `AccessToken`
だれが投票できるのかを管理するトークン(ERC721)。
このNFTを持っている人は、`ConciliatorProxy` に対して関数の実行を提案したり、提案に投票したりできる。

### `OkimochiToken`
お気持ちトークン(ERC20)。交換することで価値を維持できる。14日間交換されていないトークンは消滅する。
