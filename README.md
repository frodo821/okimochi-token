# 交換しないと減るトークン

価値を保存できないことに意味がある、かもしれない。


- [`0x0F386170187f209D21A56246b223a7e7Cdfd3CeA`](https://mumbai.polygonscan.com/address/0x0F386170187f209D21A56246b223a7e7Cdfd3CeA): ConciliatorProxy
- [`0x3BAf7c998bfCa3bcE70Ba2C5Bb82E7B180adF534`](https://mumbai.polygonscan.com/address/0x3BAf7c998bfCa3bcE70Ba2C5Bb82E7B180adF534): AccessToken
- [`0xA93133046DD0971F8ac2566E28e264F9c46b62A6`](https://mumbai.polygonscan.com/address/0xA93133046DD0971F8ac2566E28e264F9c46b62A6): OkimochiToken

## コントラクトの構成

### `ConciliatorProxy`
任意のコントラクト関数を投票ベースで呼び出すことができるコントラクト。
このコントラクトのアドレスをコントラクトのOwnerにしておけば、コミュニティの投票によって管理コマンドを実行できる。

### `AccessToken`
だれが投票できるのかを管理するトークン(ERC721)。
このNFTを持っている人は、`ConciliatorProxy` に対して関数の実行を提案したり、提案に投票したりできる。

### `OkimochiToken`
お気持ちトークン(ERC20)。交換することで価値を維持できる。14日間交換されていないトークンは消滅する。
