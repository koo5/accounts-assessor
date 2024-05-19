
three situations:
```
1)exchange rate is 2

2)500 usd revenue:
	dr 500usd bank
	cr (500usd * 2(aud/usd)) = 1000aud revenue
	dr 1000aud cr 500usd currency movement
	
3)exchange rate is 10

bank      bank,converted at-spot    currency_movement
dr500usd        dr1000aud          dr1000aud cr500usd
      made 4000aud on rate change in this period
-------------------------------------------
dr500usd        dr1000aud          dr1000aud cr500usd

==================

exchange rate is 2

500 usd revenue:
	dr 500usd bank
	cr (500usd * 2(aud/usd)) = 1000aud revenue
	dr 1000aud cr 500usd currency movement
	
exchange rate is 10

400 usd expense:
	cr 400usd bank
	dr (400usd * 10(aud/usd)) = 4000aud expense
	cr 4000aud dr 400usd currency movement

bank      bank,converted at-spot    currency_movement
dr500usd        dr1000aud          dr1000aud cr500usd
      made 4000aud on rate change in this period
cr400usd        cr4000aud          cr4000aud dr400usd
-------------------------------------------
dr100usd        cr3000aud          cr3000aud cr100usd

==================
once again with 10000usd initial balance, starting when exchange rate is 2
==================

exchange rate is 2

500 usd revenue:
	dr 500usd bank
	cr (500usd * 2(aud/usd)) = 1000aud revenue
	dr 1000aud cr 500usd currency movement
	
exchange rate is 10

400 usd expense:
	cr 400usd bank
	dr (400usd * 10(aud/usd)) = 4000aud expense
	cr 4000aud dr 400usd currency movement

bank      bank,converted at-spot    currency_movement
dr10000usd      dr20000usd         dr20000aud cr10000usd

dr500usd        dr1000aud          dr1000aud  cr500usd

cr400usd        cr4000aud          cr4000aud  dr400usd
-------------------------------------------
dr10100usd      dr17000aud         dr17000aud cr10100usd

```

see also "Difference transactions"
 